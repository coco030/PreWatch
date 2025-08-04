
package com.springmvc.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.springmvc.domain.StatDTO;
import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.repository.StatRepository;

@Service
public class StatServiceImpl implements StatService {


    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private StatRepository statRepository;

   
    // 장르 목록
    private static final List<String> GENRES = List.of(
        "Action", "Adventure", "Animation", "Biography", "Comedy", "Crime", "Documentary",
        "Drama", "Family", "Fantasy", "Film-Noir", "History", "Horror", "Music", "Musical",
        "Mystery", "Romance", "Sci-Fi", "Sport", "Thriller", "War", "Western", "Reality-TV", "Game-Show"
    );

    @Override
    public void initializeMovieGenres() {
        String selectSql = "SELECT id, genre FROM movies";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(selectSql);

        for (Map<String, Object> row : rows) {
            Long movieId = ((Number) row.get("id")).longValue();
            String genreStr = (String) row.get("genre");

            if (genreStr == null || genreStr.isBlank()) continue;

            String[] genreArray = genreStr.split(",");
            for (String rawGenre : genreArray) {
                String genre = rawGenre.trim();
                if (GENRES.contains(genre)) {
                    jdbcTemplate.update(
                        "INSERT IGNORE INTO movie_genres (movie_id, genre) VALUES (?, ?)",
                        movieId, genre
                    );
                }
            }
        }
        System.out.println("movie_genres 초기화 완료");
    }

    private static final List<String> VIOLENCE_EXPECTED_GENRES = List.of("Action", "Crime", "Thriller", "War");
    private static final List<String> HORROR_EXPECTED_GENRES = List.of("Horror", "Thriller");
    private static final List<String> SEXUAL_EXPECTED_GENRES = List.of("Drama", "Romance", "Thriller");
    private static final List<String> FAMILY_GENRES = List.of("Animation", "Family", "Musical", "Comedy");

    public static class InsightMessage {
        private String message;
        public InsightMessage(String message) { this.message = message; }
        public String getMessage() { return message; }
    }

    private static class AnalyzedFact {
        private String message;
        private double differenceScore;

        public AnalyzedFact(String message, double differenceScore) {
            this.message = message;
            this.differenceScore = differenceScore;
        }

        public String getMessage() { return message; }
        public double getDifferenceScore() { return differenceScore; }
    }

    private double calculateDifference(double movieScore, double genreAvgScore) {
        if (genreAvgScore == 0) return 0.0;
        return (movieScore - genreAvgScore) / genreAvgScore;
    }

 // generateInsights 전체 정리된 메서드
    @Override
    public List<InsightMessage> generateInsights(long movieId) {
        StatDTO movieStats = statRepository.findMovieStatsById(movieId);
        if (movieStats == null) {
            return Collections.singletonList(new InsightMessage("영화 정보를 분석할 수 없습니다."));
        }

        List<String> genres = statRepository.findGenresByMovieId(movieId);
        if (genres.isEmpty()) {
            return Collections.emptyList();
        }

        // 최종 분석 결과를 담을 리스트
        List<AnalyzedFact> allFacts = new ArrayList<>();
        // 분석 유형별로 해당되는 장르를 그룹화하기 위한 맵
        Map<String, List<String>> analysisMap = new HashMap<>();

        // 영화의 실제 점수 및 정보
        double ratingAvg = movieStats.getUserRatingAvg();
        double violenceAvg = movieStats.getViolenceScoreAvg();
        double horrorAvg = movieStats.getHorrorScoreAvg();
        double sexualAvg = movieStats.getSexualScoreAvg();
        String rated = movieStats.getRated();

        boolean isFamilyGenre = genres.stream().anyMatch(FAMILY_GENRES::contains);
        boolean isRatedForChildren = rated != null && (
            rated.equalsIgnoreCase("G") || rated.equalsIgnoreCase("All") ||
            rated.equalsIgnoreCase("PG") || rated.equalsIgnoreCase("PG-7") || rated.equalsIgnoreCase("PG-13")
        );

        // --- 분석 로직 시작 ---

        // 1. [그룹화 단계] 장르별로 분석하여 analysisMap에 유형별로 장르를 추가
        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);
            if (genreAvgStats == null) continue;

            double genreRatingAvg = genreAvgStats.getGenreRatingAvg();
            double genreViolenceAvg = genreAvgStats.getGenreViolenceScoreAvg();
            double genreHorrorAvg = genreAvgStats.getGenreHorrorScoreAvg();

            // [높은 만족도]
            if (ratingAvg >= 7.5 && calculateDifference(ratingAvg, genreRatingAvg) > 0.25) {
                analysisMap.computeIfAbsent("HIGH_RATING", k -> new ArrayList<>()).add(genre);
            }
            // [낮은 만족도]
            if (ratingAvg > 0.0 && ratingAvg <= 4.0 && calculateDifference(ratingAvg, genreRatingAvg) < -0.3) {
                analysisMap.computeIfAbsent("LOW_RATING", k -> new ArrayList<>()).add(genre);
            }
            // [기대보다 낮은 폭력성]
            if (VIOLENCE_EXPECTED_GENRES.contains(genre) && violenceAvg <= 3.0 && calculateDifference(violenceAvg, genreViolenceAvg) < -0.5) {
                analysisMap.computeIfAbsent("LOW_VIOLENCE", k -> new ArrayList<>()).add(genre);
            }
            // [기대보다 낮은 공포]
            if (HORROR_EXPECTED_GENRES.contains(genre) && horrorAvg <= 3.0 && calculateDifference(horrorAvg, genreHorrorAvg) < -0.5) {
                analysisMap.computeIfAbsent("LOW_HORROR", k -> new ArrayList<>()).add(genre);
            }
        }

        // 2. [메시지 생성 단계] 그룹화된 analysisMap을 기반으로 통합된 메시지 생성
        for (Map.Entry<String, List<String>> entry : analysisMap.entrySet()) {
            String code = entry.getKey();
            List<String> genreList = entry.getValue();

            if (genreList.isEmpty()) continue;

            // 장르 리스트를 "'장르1', '장르2'" 형태로 변환
            String genreStr = "'" + String.join("', '", genreList) + "'";
            String msg = "";

            switch (code) {
                case "HIGH_RATING":
                    msg = String.format("%s 장르 영화 중에서도 특히 만족도가 높아, 호평받은 작품입니다.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.9));
                    break;
                case "LOW_RATING":
                    msg = String.format("일부 %s 장르 팬들에게는 아쉬운 평가를 받기도 했습니다.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.4));
                    break;
                case "LOW_VIOLENCE":
                    msg = String.format("%s 장르지만, 예상과 달리 폭력적인 장면은 거의 없어 편안하게 볼 수 있어요.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.6));
                    break;
                case "LOW_HORROR":
                    msg = String.format("%s 장르임에도, 무서운 장면이 거의 없어 공포를 싫어하는 분들도 즐길 수 있습니다.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.6));
                    break;
            }
        }

        // 3. 점수 조합 및 연령 등급 등, 장르 그룹화가 필요 없는 개별 분석 추가
        StatDTO primaryGenreAvg = statRepository.getGenreAverageScores(genres.get(0));
        double violenceDiff = calculateDifference(violenceAvg, primaryGenreAvg.getGenreViolenceScoreAvg());
        double sexualDiff = calculateDifference(sexualAvg, primaryGenreAvg.getGenreSexualScoreAvg());

        if (violenceAvg >= 7.0 && sexualAvg <= 3.0 && violenceDiff > 0.3 && sexualDiff < -0.4 && genres.stream().anyMatch(VIOLENCE_EXPECTED_GENRES::contains)) {
            allFacts.add(new AnalyzedFact("선정적인 묘사 없이 액션의 쾌감에 집중한 영화입니다.", 1.2));
        }
        if (violenceAvg >= 7.0 && sexualAvg >= 7.0 && violenceDiff > 0.5 && sexualDiff > 0.5) {
            allFacts.add(new AnalyzedFact("성인 관객층을 겨냥한, 폭력성과 선정성 모두 강렬한 연출이 특징이에요.", 1.2));
        }
        //아동용이라서 내가 임의로 5점 배정
        if (horrorAvg >= 5.0 && (isFamilyGenre || isRatedForChildren)) {
            allFacts.add(new AnalyzedFact("가족 영화 또는 아동/청소년 관람가 등급임에도, 공포 지수가 높아 주의가 필요해요.", 1.5));
        }
        if (violenceAvg >= 7.0 && isRatedForChildren) {
            allFacts.add(new AnalyzedFact("아동/청소년 관람가 등급이지만 폭력성 수위가 높은 편이라 보호자의 지도가 필요할 수 있어요.", 1.4));
        }

        // 4. 우선순위에 따라 최종 메시지 선택
        allFacts.sort(Comparator.comparingDouble(AnalyzedFact::getDifferenceScore).reversed());

        List<InsightMessage> finalInsights = new ArrayList<>();
        int maxInsights = 3;
        for (AnalyzedFact fact : allFacts) {
            if (finalInsights.size() >= maxInsights) break;
            finalInsights.add(new InsightMessage(fact.getMessage()));
        }

        if (finalInsights.isEmpty()) {
            finalInsights.add(new InsightMessage("이 영화는 전반적으로 장르의 특징을 무난하게 따르고 있습니다."));
        }

        return finalInsights;
    }
    
    
    private List<AnalyzedFact> analyzeGenreContrast(StatDTO movieStats, List<String> genres) {
        List<AnalyzedFact> facts = new ArrayList<>();

        Map<String, Double> totalDiffs = new HashMap<>();
        for (String genre : genres) {
            StatDTO avg = statRepository.getGenreAverageScores(genre);
            if (avg == null) continue;

            double ratingDiff = Math.abs(movieStats.getUserRatingAvg() - avg.getGenreRatingAvg()) / (avg.getGenreRatingAvg() + 1e-6);
            double violenceDiff = Math.abs(movieStats.getViolenceScoreAvg() - avg.getGenreViolenceScoreAvg()) / (avg.getGenreViolenceScoreAvg() + 1e-6);
            double horrorDiff = Math.abs(movieStats.getHorrorScoreAvg() - avg.getGenreHorrorScoreAvg()) / (avg.getGenreHorrorScoreAvg() + 1e-6);
            double sexualDiff = Math.abs(movieStats.getSexualScoreAvg() - avg.getGenreSexualScoreAvg()) / (avg.getGenreSexualScoreAvg() + 1e-6);

            double totalDiff = ratingDiff * 0.3 + violenceDiff * 0.3 + horrorDiff * 0.2 + sexualDiff * 0.2;
            totalDiffs.put(genre, totalDiff);
        }
        if (totalDiffs.isEmpty()) return facts;
        // 편차가 가장 큰 장르 찾기
        String outlierGenre = totalDiffs.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse(null);
        double diffScore = totalDiffs.get(outlierGenre);
        if (outlierGenre != null && diffScore > 0.4) {
            String msg = String.format("이 영화는 '%s' 장르로 분류되었지만, 주요 평가 지표에서 평균과 큰 차이를 보입니다. 전형적인 %s 장르와는 다른 독특한 작품입니다.", outlierGenre, outlierGenre);
            facts.add(new AnalyzedFact(msg, diffScore));
        }

        return facts;
    }
    
 // getAllowedRatingsForGuest() 메서드
    public List<String> getAllowedRatingsForGuest(String rated) {
        if (rated == null) return Collections.emptyList();

        return switch (rated) {
            case "전체관람가", "G" -> List.of("전체관람가", "G", "PG", "PG-13");
            case "PG" -> List.of("전체관람가", "G", "PG", "PG-13");
            case "12세", "PG-13" -> List.of("전체관람가", "G", "PG", "12세", "PG-13");
            case "15세" -> List.of("전체관람가", "G", "PG", "12세", "PG-13", "15세");
            case "청불", "R", "18+" -> List.of("전체관람가", "G", "PG", "12세", "PG-13", "15세", "청불", "R", "18+");
            default -> List.of("전체관람가", "G", "PG", "12세", "PG-13");
        };
    }

    @Override
    public List<StatDTO> recommendForGuest(long movieId) {
        // 1. 기준 영화의 통계 정보와 장르 정보 조회
        StatDTO stat = statRepository.findMovieStatsById(movieId);
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        stat.setGenres(genres);

        // 2. 기준 영화의 연령등급에 따라 허용 등급 리스트 계산
        List<String> allowedRatings = getAllowedRatingsForGuest(stat.getRated());

        // 3. 추천 영화 목록 조회
        List<StatDTO> recommendedMovies = statRepository.findSimilarMoviesWithGenres(
            stat.getUserRatingAvg(),
            stat.getViolenceScoreAvg(),
            stat.getHorrorScoreAvg(),
            stat.getSexualScoreAvg(),
            genres,
            allowedRatings,
            movieId
        );
        // 추천된 각 영화에 대해 장르 정보를 조회하고 DTO에 설정
        for (StatDTO recommendedMovie : recommendedMovies) {
            List<String> movieGenres = statRepository.findGenresByMovieId(recommendedMovie.getMovieId());
            recommendedMovie.setGenres(movieGenres);
        }
        return recommendedMovies;
    }
    
    
    
    //개인화 로그인한 상태에서 비슷한 영화 취향 분석
 // 사용자 취향을 고려한 허용 등급 계산
    private List<String> getSmartAllowedRatings(String baseMovieRated, Map<String, Double> userDeviationScores) {
        // 기본적으로는 기준 영화와 동일한 등급 체계 사용
        List<String> baseAllowedRatings = getAllowedRatingsForGuest(baseMovieRated);
        
        // 사용자 취향 분석이 없으면 기본 등급만 허용
        if (userDeviationScores.isEmpty()) {
            return baseAllowedRatings;
        }
        
        // 사용자 취향 분석
        double violencePref = userDeviationScores.getOrDefault("액션", 0.0);
        double horrorPref = userDeviationScores.getOrDefault("스릴", 0.0);
        double sexualPref = userDeviationScores.getOrDefault("감성", 0.0);
        
        // 자극적인 콘텐츠를 싫어하는 사용자
        boolean prefersLowIntensity = violencePref < -1.5 && horrorPref < -1.5 && sexualPref < -1.5;
        
        // 자극적인 콘텐츠를 좋아하는 사용자  
        boolean prefersHighIntensity = violencePref > 1.5 || horrorPref > 1.5 || sexualPref > 1.5;
        
        List<String> smartRatings = new ArrayList<>(baseAllowedRatings);
        
        if (prefersLowIntensity) {
            // 순화된 콘텐츠를 선호하는 사용자: 더 낮은 등급으로 제한
            smartRatings = smartRatings.stream()
                .filter(rating -> isLowerOrEqualRating(rating, baseMovieRated))
                .collect(Collectors.toList());
        } else if (prefersHighIntensity && isAdultSafeRating(baseMovieRated)) {
            // 자극적인 콘텐츠를 선호하고 기준 영화가 성인 안전 등급인 경우: 한 단계 상향 허용
            String higherRating = getNextHigherRating(baseMovieRated);
            if (higherRating != null && !smartRatings.contains(higherRating)) {
                smartRatings.add(higherRating);
            }
        }
        
        return smartRatings.isEmpty() ? baseAllowedRatings : smartRatings;
    }

    // 등급 비교 헬퍼 메서드들
    private boolean isLowerOrEqualRating(String rating, String baseRating) {
        List<String> ratingOrder = List.of("전체관람가", "G", "PG", "12세", "PG-13", "15세", "청불", "R", "18+");
        int ratingIndex = ratingOrder.indexOf(rating);
        int baseIndex = ratingOrder.indexOf(baseRating);
        return ratingIndex != -1 && baseIndex != -1 && ratingIndex <= baseIndex;
    }

    private boolean isAdultSafeRating(String rating) {
        return List.of("12세", "PG-13", "15세").contains(rating);
    }

    private String getNextHigherRating(String currentRating) {
        Map<String, String> nextRating = Map.of(
            "전체관람가", "12세",
            "G", "PG-13", 
            "PG", "PG-13",
            "12세", "15세",
            "PG-13", "15세",
            "15세", "청불"
        );
        return nextRating.get(currentRating);
    }
    
    // 08.02
    @Override
    public List<StatDTO> recommendForLoggedInUser(long movieId, String memberId) {
        System.out.println("[DEBUG] 편차 계산 시작 - memberId: " + memberId);
        StatDTO stat = statRepository.findMovieStatsById(movieId);
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        
        // 장르가 없다면 바로 종료
        if (genres == null || genres.isEmpty()) {
            System.out.println("[DEBUG] 기준 영화의 장르 정보가 없습니다. 영화 추천을 종료합니다.");
            return Collections.emptyList();
        }
        stat.setGenres(genres);

        // 유저의 취향과 편차를 반영한 점수 계산
        Map<String, Double> userDeviationScores = calculateUserDeviationScores(memberId);
        double adjustedRating = stat.getUserRatingAvg() + userDeviationScores.getOrDefault("작품성", 0.0) * 0.5;
        double adjustedViolence = stat.getViolenceScoreAvg() + userDeviationScores.getOrDefault("액션", 0.0) * 0.5;
        double adjustedHorror = stat.getHorrorScoreAvg() + userDeviationScores.getOrDefault("스릴", 0.0) * 0.5;
        double adjustedSexual = stat.getSexualScoreAvg() + userDeviationScores.getOrDefault("감성", 0.0) * 0.5;

        // 0~10 범위 제한 
        adjustedRating = Math.max(0, Math.min(10, adjustedRating));
        adjustedViolence = Math.max(0, Math.min(10, adjustedViolence));
        adjustedHorror = Math.max(0, Math.min(10, adjustedHorror));
        adjustedSexual = Math.max(0, Math.min(10, adjustedSexual));

        List<String> allowedRatings = List.of("전체관람가", "G", "PG", "12세", "PG-13", "15세", "청불", "R", "18+");

        // 추천된 영화 목록 조회 (기본 정보만 있음)
        List<StatDTO> recommendedMovies = statRepository.findSimilarMoviesForLoggedInUser(
            adjustedRating,
            adjustedViolence,
            adjustedHorror,
            adjustedSexual,
            genres,
            allowedRatings,
            movieId,
            userDeviationScores
        );

        for (StatDTO recommendedMovie : recommendedMovies) {
            List<String> movieGenres = statRepository.findGenresByMovieId(recommendedMovie.getMovieId());
            recommendedMovie.setGenres(movieGenres);
        }
        System.out.println("[DEBUG] 최종 추천된 영화 (장르 포함): " + recommendedMovies);
        for (StatDTO recommendedMovie : recommendedMovies) {
            System.out.println("[DEBUG] 추천 영화 ID: " + recommendedMovie.getMovieId() + " 장르: " + recommendedMovie.getGenres());
        }
        return recommendedMovies; 
    }


    @Override
    public Map<String, Double> calculateUserDeviationScores(String memberId) {
        System.out.println("\n===== [START] 사용자 취향 편차 계산 (MEMBER ID: " + memberId + ") =====");

        // 1. 사용자가 리뷰를 남긴 모든 영화의 상세 데이터를 가져옵니다.
        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);

        // 최소 n개 이상 리뷰
        if (reviewedMovies == null || reviewedMovies.size() < 0) {
            System.out.println("[INFO] 리뷰 개수가 " + (reviewedMovies == null ? 0 : reviewedMovies.size()) + "개로 분석 기준(3개)에 미치지 못하여 기본 추천을 제공합니다.");
            System.out.println("===== [END] 사용자 취향 편차 계산 =====\n");
            return Collections.emptyMap();
        }
        System.out.println("[STEP 1] 사용자가 리뷰한 영화 " + reviewedMovies.size() + "건 조회 완료.");

        // 각 항목(작품성, 액션 등)에 대한 '편차'들을 저장할 리스트
        List<Double> ratingDeviations = new ArrayList<>();
        List<Double> violenceDeviations = new ArrayList<>();
        List<Double> horrorDeviations = new ArrayList<>();
        List<Double> sexualDeviations = new ArrayList<>();

        System.out.println("\n[STEP 2] 각 영화별 '개인 점수 - 장르 평균 점수' 편차 계산 시작...");
        // 2. 사용자가 리뷰한 각 영화를 순회하며 편차를 계산
        for (TasteAnalysisDataDTO review : reviewedMovies) {
            Long movieId = review.getMovieId();
            List<String> genres = statRepository.findGenresByMovieId(movieId);
            
            if (genres.isEmpty()) {
                System.out.println("  - MOVIE ID " + movieId + ": 장르 정보가 없어 분석에서 제외합니다.");
                continue;
            }

            String primaryGenre = genres.get(0); // 대표 장르로 분석
            StatDTO genreAverage = statRepository.getGenreAverageScores(primaryGenre);

            System.out.println("  - MOVIE ID " + movieId + " (장르: " + genres + ")");

            // 작품성 편차: 모든 영화에 대해 계산
            if (review.getMyUserRating() != null) {
                double deviation = review.getMyUserRating() - genreAverage.getGenreRatingAvg();
                ratingDeviations.add(deviation);
                System.out.printf("    > 작품성 편차: (내 점수 %.1f) - (장르 평균 %.1f) = %.1f%n", (double)review.getMyUserRating(), genreAverage.getGenreRatingAvg(), deviation);
            }

            // 
            // 폭력성 편차: VIOLENCE_EXPECTED_GENRES 에 포함된 장르일 경우에만 계산합니다.
            if (review.getMyViolenceScore() != null && genres.stream().anyMatch(VIOLENCE_EXPECTED_GENRES::contains)) {
                double deviation = review.getMyViolenceScore() - genreAverage.getGenreViolenceScoreAvg();
                violenceDeviations.add(deviation);
                System.out.printf("    > (폭력성 관련 장르) 편차 계산: (내 점수 %.1f) - (장르 평균 %.1f) = %.1f%n", (double)review.getMyViolenceScore(), genreAverage.getGenreViolenceScoreAvg(), deviation);
            }

            // 공포성 편차: HORROR_EXPECTED_GENRES 에 포함된 장르일 경우에만 계산합니다.
            if (review.getMyHorrorScore() != null && genres.stream().anyMatch(HORROR_EXPECTED_GENRES::contains)) {
                double deviation = review.getMyHorrorScore() - genreAverage.getGenreHorrorScoreAvg();
                horrorDeviations.add(deviation);
                System.out.printf("    > (공포성 관련 장르) 편차 계산: (내 점수 %.1f) - (장르 평균 %.1f) = %.1f%n", (double)review.getMyHorrorScore(), genreAverage.getGenreHorrorScoreAvg(), deviation);
            }

            // 선정성 편차: SEXUAL_EXPECTED_GENRES 에 포함된 장르일 경우에만 계산합니다.
            if (review.getMySexualScore() != null && genres.stream().anyMatch(SEXUAL_EXPECTED_GENRES::contains)) {
                double deviation = review.getMySexualScore() - genreAverage.getGenreSexualScoreAvg();
                sexualDeviations.add(deviation);
                System.out.printf("    > (선정성 관련 장르) 편차 계산: (내 점수 %.1f) - (장르 평균 %.1f) = %.1f%n", (double)review.getMySexualScore(), genreAverage.getGenreSexualScoreAvg(), deviation);
            }
            // =======================================================================
        }

        // 4. 계산된 편차들의 평균을 내어 사용자의 최종 취향 점수로 확정
        Map<String, Double> finalDeviationScores = new HashMap<>();
        finalDeviationScores.put("작품성", calculateAverage(ratingDeviations, "작품성"));
        finalDeviationScores.put("액션", calculateAverage(violenceDeviations, "액션"));
        finalDeviationScores.put("스릴", calculateAverage(horrorDeviations, "스릴"));
        finalDeviationScores.put("감성", calculateAverage(sexualDeviations, "감성"));

        System.out.println("\n[STEP 3] 최종 사용자 취향 편차 점수 도출 완료.");
        System.out.println("  " + finalDeviationScores);
        System.out.println("===== [END] 사용자 취향 편차 계산 =====\n");

        return finalDeviationScores;
    }

    // 편차 리스트의 평균을 계산하는 헬퍼 메소드 (디버깅 로그 추가)
    private double calculateAverage(List<Double> numbers, String type) {
        if (numbers == null || numbers.isEmpty()) {
            System.out.println("  - 최종 '" + type + "' 편차: 계산할 데이터 없음. [0.0]");
            return 0.0;
        }
        double average = numbers.stream().mapToDouble(d -> d).average().orElse(0.0);
        System.out.printf("  - 최종 '%s' 편차: %s -> 평균 [%.2f]%n", type, numbers, average);
        return average;
    }
	
	// 편차 리스트의 평균을 계산하는 헬퍼 메소드
	private double calculateAverage(List<Double> numbers) {
	    if (numbers == null || numbers.isEmpty()) {
	        return 0.0;
	    }
	    return numbers.stream().mapToDouble(d -> d).average().orElse(0.0);
	}
    
    public double calculateWeightedAverage(List<TasteAnalysisDataDTO> reviewedMovies, String type) {
        double sum = 0.0;
        int count = 0;

        System.out.println("[DEBUG] 유저 리뷰 조회 결과 - 개수: " + reviewedMovies.size());

        for (TasteAnalysisDataDTO dto : reviewedMovies) {

            Double value = switch (type) {
                case "rating" -> dto.getMyUserRating() != null ? dto.getMyUserRating().doubleValue() : null;
                case "violence" -> dto.getMyViolenceScore() != null ? dto.getMyViolenceScore().doubleValue() : null;
                case "horror" -> dto.getMyHorrorScore() != null ? dto.getMyHorrorScore().doubleValue() : null;
                case "sexual" -> dto.getMySexualScore() != null ? dto.getMySexualScore().doubleValue() : null;
                default -> null;
            };

            if (value != null) {
                sum += value;
                count++;

                System.out.println("[DEBUG] [" + type + "] 유저 점수: " + value);
            }
        }

        double result = (count == 0) ? 0.0 : sum / count;
        System.out.println("[DEBUG] [" + type + "] 평균 점수 계산 완료 → 평균: " + result);
        return result;
    }    
}
