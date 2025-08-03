
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
        if (genres.isEmpty()) return Collections.emptyList();

        boolean isHorrorExpected = genres.stream().anyMatch(HORROR_EXPECTED_GENRES::contains);
        boolean isFamilyGenre = genres.stream().anyMatch(FAMILY_GENRES::contains);
        String rated = movieStats.getRated();
        boolean isRatedForChildren = rated != null && (
            rated.equalsIgnoreCase("G") ||
            rated.equalsIgnoreCase("All") ||
            rated.equalsIgnoreCase("PG") ||
            rated.equalsIgnoreCase("PG-7") ||
            rated.equalsIgnoreCase("PG-13")
        );

        Map<String, List<String>> analysisMap = new HashMap<>();
        List<AnalyzedFact> allFacts = new ArrayList<>();

        double ratingAvg = movieStats.getUserRatingAvg();
        double violenceAvg = movieStats.getViolenceScoreAvg();
        double horrorAvg = movieStats.getHorrorScoreAvg();
        double sexualAvg = movieStats.getSexualScoreAvg();

        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);
            double genreRatingAvg = genreAvgStats.getGenreRatingAvg();
            double genreViolenceAvg = genreAvgStats.getGenreViolenceScoreAvg();
            double genreHorrorAvg = genreAvgStats.getGenreHorrorScoreAvg();
            double genreSexualAvg = genreAvgStats.getGenreSexualScoreAvg();

            if (ratingAvg > 0.0 && ratingAvg >= 7.0 && calculateDifference(ratingAvg, genreRatingAvg) > 0.25) {
                analysisMap.computeIfAbsent("HIGH_RATING", k -> new ArrayList<>()).add(genre);
            }
            if (sexualAvg >= 7.0) {
                analysisMap.computeIfAbsent("HIGH_SEXUAL", k -> new ArrayList<>()).add(genre);
            }
            if (violenceAvg <= 3.0 && VIOLENCE_EXPECTED_GENRES.contains(genre)) {
                analysisMap.computeIfAbsent("LOW_VIOLENCE", k -> new ArrayList<>()).add(genre);
            }
            if (horrorAvg <= 3.0 && HORROR_EXPECTED_GENRES.contains(genre)) {
                analysisMap.computeIfAbsent("LOW_HORROR", k -> new ArrayList<>()).add(genre);
            }
            if (sexualAvg <= 3.0 && SEXUAL_EXPECTED_GENRES.contains(genre)) {
                analysisMap.computeIfAbsent("LOW_SEXUAL", k -> new ArrayList<>()).add(genre);
            }
            if (ratingAvg > 0.0 && ratingAvg <= 4.0) {
                analysisMap.computeIfAbsent("LOW_RATING", k -> new ArrayList<>()).add(genre);
            }
        }

        String primaryGenre = genres.get(0);
        StatDTO primaryGenreAvg = statRepository.getGenreAverageScores(primaryGenre);
        double violenceDiff = calculateDifference(violenceAvg, primaryGenreAvg.getGenreViolenceScoreAvg());
        double sexualDiff = calculateDifference(sexualAvg, primaryGenreAvg.getGenreSexualScoreAvg());

        if (violenceAvg >= 7.0 && sexualAvg <= 3.0 && violenceDiff > 0.3 && sexualDiff < -0.4) {
            allFacts.add(new AnalyzedFact("선정적인 묘사 없이 액션에 집중한 영화입니다.", Math.abs(violenceDiff) + Math.abs(sexualDiff)));
        }
        if (violenceAvg >= 7.0 && sexualAvg >= 7.0 && violenceDiff > 0.5 && sexualDiff > 0.5) {
            allFacts.add(new AnalyzedFact("성인 관객층을 겨냥한 강렬한 연출이 특징이에요.", violenceDiff + sexualDiff));
        }

        if (horrorAvg >= 5.0 && (isFamilyGenre || isRatedForChildren)) {
            String msg = "가족, 아동, 또는 전체관람가 영화임에도 불구하고 공포 지수가 높아 주의가 필요해요.";
            allFacts.add(new AnalyzedFact(msg, 1.5));
        }

        for (Map.Entry<String, List<String>> entry : analysisMap.entrySet()) {
            String code = entry.getKey();
            List<String> genreList = entry.getValue();
            if (genreList.isEmpty()) continue;

            String genreStr = "'" + String.join("', '", genreList) + "'";
            String msg = "";

            switch (code) {
                case "HIGH_RATING":
                    msg = String.format("만족도 지수가 %s 장르의 평균보다 높네요. 호평을 받은 작품입니다.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.8));
                    break;
                case "HIGH_SEXUAL":
                    msg = String.format("같은 %s 장르에서 비교했을 때, 선정성 지수가 매우 높아요. 자극적인 장면이 있을 수 있어요.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 1.0));
                    break;
                case "LOW_RATING":
                    msg = String.format("일부 '%s' 장르 팬들에겐 만족도가 낮은 편이에요.", genreStr);
                    allFacts.add(new AnalyzedFact(msg, 0.4));
                    break;
                case "LOW_VIOLENCE":
                    msg = String.format("'%s' 장르지만, 폭력적인 장면은 거의 없어요.", primaryGenre);
                    allFacts.add(new AnalyzedFact(msg, 0.5));
                    break;
                case "LOW_SEXUAL":
                    msg = String.format("'%s' 장르로 분류되지만, 선정성은 거의 없습니다.", primaryGenre);
                    allFacts.add(new AnalyzedFact(msg, 0.5));
                    break;
                case "LOW_HORROR":
                    msg = String.format("'%s' 장르지만 공포 요소는 거의 없어요.", primaryGenre);
                    allFacts.add(new AnalyzedFact(msg, 0.5));
                    break;
            }
        }

        allFacts.sort(Comparator.comparingDouble(AnalyzedFact::getDifferenceScore).reversed());
        List<InsightMessage> finalInsights = new ArrayList<>();
        int max = 3;
        for (int i = 0; i < Math.min(max, allFacts.size()); i++) {
            finalInsights.add(new InsightMessage(allFacts.get(i).getMessage()));
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
        stat.setGenres(genres); // StatDTO 내부 필드에 장르 저장

        // 2. 기준 영화의 연령등급에 따라 허용 등급 리스트 계산
        List<String> allowedRatings = getAllowedRatingsForGuest(stat.getRated());

        // 3. 추천 영화 목록 조회 (장르 정보는 아직 없음)
        List<StatDTO> recommendedMovies = statRepository.findSimilarMoviesWithGenres(
            stat.getUserRatingAvg(),
            stat.getViolenceScoreAvg(),
            stat.getHorrorScoreAvg(),
            stat.getSexualScoreAvg(),
            genres,
            allowedRatings,
            movieId
        );

        // ★★★★★★★★★★ 핵심 수정 부분 ★★★★★★★★★★
        // 추천된 각 영화에 대해 장르 정보를 조회하고 DTO에 설정합니다.
        for (StatDTO recommendedMovie : recommendedMovies) {
            List<String> movieGenres = statRepository.findGenresByMovieId(recommendedMovie.getMovieId());
            recommendedMovie.setGenres(movieGenres);
        }
        // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★

        return recommendedMovies; // 장르가 채워진 리스트를 반환
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
        
        // 장르가 없다면 바로 종료 (기존 로직 유지)
        if (genres == null || genres.isEmpty()) {
            System.out.println("[DEBUG] 기준 영화의 장르 정보가 없습니다. 영화 추천을 종료합니다.");
            return Collections.emptyList();
        }
        stat.setGenres(genres);

        // 유저의 취향과 편차를 반영한 점수 계산 (기존 로직 유지)
        Map<String, Double> userDeviationScores = calculateUserDeviationScores(memberId);
        double adjustedRating = stat.getUserRatingAvg() + userDeviationScores.getOrDefault("작품성", 0.0) * 0.5;
        double adjustedViolence = stat.getViolenceScoreAvg() + userDeviationScores.getOrDefault("액션", 0.0) * 0.5;
        double adjustedHorror = stat.getHorrorScoreAvg() + userDeviationScores.getOrDefault("스릴", 0.0) * 0.5;
        double adjustedSexual = stat.getSexualScoreAvg() + userDeviationScores.getOrDefault("감성", 0.0) * 0.5;

        // 0~10 범위 제한 (기존 로직 유지)
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

        // ★★★★★★★★★★ 핵심 수정 부분 ★★★★★★★★★★
        // 추천된 각 영화에 대해 장르 정보를 조회하고 DTO에 설정합니다.
        for (StatDTO recommendedMovie : recommendedMovies) {
            // 추천된 영화의 ID를 사용하여 장르 목록을 조회합니다.
            List<String> movieGenres = statRepository.findGenresByMovieId(recommendedMovie.getMovieId());
            // 조회된 장르 목록을 DTO에 설정합니다.
            recommendedMovie.setGenres(movieGenres);
        }
        // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★


        // 이제 장르가 포함된 추천 영화 리스트가 완성되었습니다.
        System.out.println("[DEBUG] 최종 추천된 영화 (장르 포함): " + recommendedMovies);

        // 각 추천 영화의 장르를 확인하고 출력
        for (StatDTO recommendedMovie : recommendedMovies) {
            // 이제 장르가 정상적으로 출력됩니다.
            System.out.println("[DEBUG] 추천 영화 ID: " + recommendedMovie.getMovieId() + " 장르: " + recommendedMovie.getGenres());
        }

        return recommendedMovies; // 장르가 채워진 리스트를 반환
    }


	@Override
	public Map<String, Double> calculateUserDeviationScores(String memberId) {
	    // 1. 사용자가 리뷰를 남긴 모든 영화의 상세 데이터를 가져옵니다.
	    List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);
	
	    // 최소 3개 이상 리뷰가 있어야 신뢰성 있다고 판단 (값은 조절 가능)
	    if (reviewedMovies == null || reviewedMovies.size() < 3) {
	        return Collections.emptyMap();
	    }
	
	    // 각 항목(작품성, 액션 등)에 대한 '편차'들을 저장할 리스트
	    List<Double> ratingDeviations = new ArrayList<>();
	    List<Double> violenceDeviations = new ArrayList<>();
	    List<Double> horrorDeviations = new ArrayList<>();
	    List<Double> sexualDeviations = new ArrayList<>();
	
	    // 2. 사용자가 리뷰한 각 영화를 순회하며 편차를 계산합니다.
	    for (TasteAnalysisDataDTO review : reviewedMovies) {
	        // 이 영화의 장르들을 가져옵니다. (movieId는 TasteAnalysisDataDTO에 추가 필요, 아래 3단계 참고)
	        List<String> genres = statRepository.findGenresByMovieId(review.getMovieId()); 
	        if (genres.isEmpty()) {
	            continue; // 장르 정보가 없으면 분석에서 제외
	        }
	
	        // 대표 장르(첫 번째 장르)의 평균 점수를 가져옵니다.
	        // (더 정교하게 하려면 모든 장르의 평균을 내야 하지만, 일단 대표 장르로 단순화)
	        StatDTO genreAverage = statRepository.getGenreAverageScores(genres.get(0));
	
	        // 3. [내가 준 점수] - [그 영화의 장르 평균 점수] 를 계산하여 리스트에 추가
	        if (review.getMyUserRating() != null) {
	            ratingDeviations.add(review.getMyUserRating() - genreAverage.getGenreRatingAvg());
	        }
	        if (review.getMyViolenceScore() != null) {
	            violenceDeviations.add(review.getMyViolenceScore() - genreAverage.getGenreViolenceScoreAvg());
	        }
	        if (review.getMyHorrorScore() != null) {
	            horrorDeviations.add(review.getMyHorrorScore() - genreAverage.getGenreHorrorScoreAvg());
	        }
	        if (review.getMySexualScore() != null) {
	            sexualDeviations.add(review.getMySexualScore() - genreAverage.getGenreSexualScoreAvg());
	        }
	    }
	
	    // 4. 계산된 편차들의 평균을 내어 사용자의 최종 취향 점수로 확정합니다.
	    Map<String, Double> finalDeviationScores = new HashMap<>();
	    finalDeviationScores.put("작품성", calculateAverage(ratingDeviations));
	    finalDeviationScores.put("액션", calculateAverage(violenceDeviations));
	    finalDeviationScores.put("스릴", calculateAverage(horrorDeviations));
	    finalDeviationScores.put("감성", calculateAverage(sexualDeviations));
	
	    return finalDeviationScores;
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
