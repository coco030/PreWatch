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

    //TMDB 한국어 장르 목록
    private static final List<String> GENRES = List.of(
        "액션", "모험", "애니메이션", "코미디", "범죄", "다큐멘터리", "드라마",
        "가족", "판타지", "역사", "공포", "음악", "미스터리", "로맨스",
        "SF", "TV 영화", "스릴러", "전쟁", "서부"
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

    // 기대 장르도 한국어로 변경
    private static final List<String> VIOLENCE_EXPECTED_GENRES = List.of("액션", "범죄", "스릴러", "전쟁");
    private static final List<String> HORROR_EXPECTED_GENRES = List.of("공포", "스릴러", "미스터리");
    private static final List<String> SEXUAL_EXPECTED_GENRES = List.of("드라마", "로맨스", "스릴러");
    private static final List<String> FAMILY_GENRES = List.of("애니메이션", "가족", "음악", "코미디");

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

        List<AnalyzedFact> allFacts = new ArrayList<>();
        Map<String, List<String>> analysisMap = new HashMap<>();

        double ratingAvg = movieStats.getUserRatingAvg();
        double violenceAvg = movieStats.getViolenceScoreAvg();
        double horrorAvg = movieStats.getHorrorScoreAvg();
        double sexualAvg = movieStats.getSexualScoreAvg();
        String rated = movieStats.getRated();

        boolean isFamilyGenre = genres.stream().anyMatch(FAMILY_GENRES::contains);
        boolean isRatedForChildren = rated != null && (
            rated.equalsIgnoreCase("G") || rated.equalsIgnoreCase("All") ||
            rated.equalsIgnoreCase("PG") || rated.equalsIgnoreCase("PG-7") || rated.equalsIgnoreCase("PG-13") ||
            rated.equals("전체관람가") || rated.equals("12세")
        );

        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);
            if (genreAvgStats == null) continue;

            double genreRatingAvg = genreAvgStats.getGenreRatingAvg();
            double genreViolenceAvg = genreAvgStats.getGenreViolenceScoreAvg();
            double genreHorrorAvg = genreAvgStats.getGenreHorrorScoreAvg();

            if (ratingAvg >= 7.5 && calculateDifference(ratingAvg, genreRatingAvg) > 0.25) {
                analysisMap.computeIfAbsent("HIGH_RATING", k -> new ArrayList<>()).add(genre);
            }
            if (ratingAvg > 0.0 && ratingAvg <= 4.0 && calculateDifference(ratingAvg, genreRatingAvg) < -0.3) {
                analysisMap.computeIfAbsent("LOW_RATING", k -> new ArrayList<>()).add(genre);
            }
            if (VIOLENCE_EXPECTED_GENRES.contains(genre) && violenceAvg <= 3.0 && calculateDifference(violenceAvg, genreViolenceAvg) < -0.5) {
                analysisMap.computeIfAbsent("LOW_VIOLENCE", k -> new ArrayList<>()).add(genre);
            }
            if (HORROR_EXPECTED_GENRES.contains(genre) && horrorAvg <= 3.0 && calculateDifference(horrorAvg, genreHorrorAvg) < -0.5) {
                analysisMap.computeIfAbsent("LOW_HORROR", k -> new ArrayList<>()).add(genre);
            }
        }

        for (Map.Entry<String, List<String>> entry : analysisMap.entrySet()) {
            String code = entry.getKey();
            List<String> genreList = entry.getValue();

            if (genreList.isEmpty()) continue;

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

        StatDTO primaryGenreAvg = statRepository.getGenreAverageScores(genres.get(0));
        if (primaryGenreAvg != null) {
            double violenceDiff = calculateDifference(violenceAvg, primaryGenreAvg.getGenreViolenceScoreAvg());
            double sexualDiff = calculateDifference(sexualAvg, primaryGenreAvg.getGenreSexualScoreAvg());

            if (violenceAvg >= 7.0 && sexualAvg <= 3.0 && violenceDiff > 0.3 && sexualDiff < -0.4 && genres.stream().anyMatch(VIOLENCE_EXPECTED_GENRES::contains)) {
                allFacts.add(new AnalyzedFact("선정적인 묘사 없이 액션의 쾌감에 집중한 영화입니다.", 1.2));
            }
            if (violenceAvg >= 7.0 && sexualAvg >= 7.0 && violenceDiff > 0.5 && sexualDiff > 0.5) {
                allFacts.add(new AnalyzedFact("성인 관객층을 겨냥한, 폭력성과 선정성 모두 강렬한 연출이 특징이에요.", 1.2));
            }
        }
        
        if (horrorAvg >= 5.0 && (isFamilyGenre || isRatedForChildren)) {
            allFacts.add(new AnalyzedFact("가족 영화 또는 아동/청소년 관람가 등급임에도, 공포 지수가 높아 주의가 필요해요.", 1.5));
        }
        if (violenceAvg >= 7.0 && isRatedForChildren) {
            allFacts.add(new AnalyzedFact("아동/청소년 관람가 등급이지만 폭력성 수위가 높은 편이라 보호자의 지도가 필요할 수 있어요.", 1.4));
        }

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
        StatDTO stat = statRepository.findMovieStatsById(movieId);
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        stat.setGenres(genres);

        List<String> allowedRatings = getAllowedRatingsForGuest(stat.getRated());

        List<StatDTO> recommendedMovies = statRepository.findSimilarMoviesWithGenres(
            stat.getUserRatingAvg(),
            stat.getViolenceScoreAvg(),
            stat.getHorrorScoreAvg(),
            stat.getSexualScoreAvg(),
            genres,
            allowedRatings,
            movieId
        );
        for (StatDTO recommendedMovie : recommendedMovies) {
            List<String> movieGenres = statRepository.findGenresByMovieId(recommendedMovie.getMovieId());
            recommendedMovie.setGenres(movieGenres);
        }
        return recommendedMovies;
    }
    
    @Override
    public List<StatDTO> recommendForLoggedInUser(long movieId, String memberId) {
        System.out.println("[DEBUG] 편차 계산 시작 - memberId: " + memberId);
        StatDTO stat = statRepository.findMovieStatsById(movieId);
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        
        if (genres == null || genres.isEmpty()) {
            System.out.println("[DEBUG] 기준 영화의 장르 정보가 없습니다. 영화 추천을 종료합니다.");
            return Collections.emptyList();
        }
        stat.setGenres(genres);

        Map<String, Double> userDeviationScores = calculateUserDeviationScores(memberId);
        
        // ("작품성", "액션", "스릴", "감성")
        double adjustedRating = stat.getUserRatingAvg() + userDeviationScores.getOrDefault("작품성", 0.0) * 0.5;
        double adjustedViolence = stat.getViolenceScoreAvg() + userDeviationScores.getOrDefault("액션", 0.0) * 0.5;
        double adjustedHorror = stat.getHorrorScoreAvg() + userDeviationScores.getOrDefault("스릴", 0.0) * 0.5; 
        double adjustedSexual = stat.getSexualScoreAvg() + userDeviationScores.getOrDefault("감성", 0.0) * 0.5; 

        adjustedRating = Math.max(0, Math.min(10, adjustedRating));
        adjustedViolence = Math.max(0, Math.min(10, adjustedViolence));
        adjustedHorror = Math.max(0, Math.min(10, adjustedHorror));
        adjustedSexual = Math.max(0, Math.min(10, adjustedSexual));

        List<String> allowedRatings = List.of("전체관람가", "G", "PG", "12세", "PG-13", "15세", "청불", "R", "18+");

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
        return recommendedMovies; 
    }

    @Override
    public Map<String, Double> calculateUserDeviationScores(String memberId) {
        System.out.println("\n===== [START] 사용자 취향 편차 계산 (MEMBER ID: " + memberId + ") =====");

        List<TasteAnalysisDataDTO> reviewedMovies = statRepository.findTasteAnalysisData(memberId);

        if (reviewedMovies == null || reviewedMovies.size() < 3) { 
            System.out.println("[INFO] 리뷰 개수가 부족하여 기본 추천을 제공합니다.");
            return Collections.emptyMap();
        }

        List<Double> ratingDeviations = new ArrayList<>();
        List<Double> violenceDeviations = new ArrayList<>();
        List<Double> horrorDeviations = new ArrayList<>();
        List<Double> sexualDeviations = new ArrayList<>();

        for (TasteAnalysisDataDTO review : reviewedMovies) {
            Long movieId = review.getMovieId();
            if (movieId == null) continue;

            List<String> genres = statRepository.findGenresByMovieId(movieId);
            if (genres.isEmpty()) continue;

            StatDTO movieStats = statRepository.findMovieStatsById(movieId);
            
            if (review.getMyUserRating() != null && movieStats != null && movieStats.getUserRatingAvg() > 0) {
                double deviation = (double)review.getMyUserRating() - movieStats.getUserRatingAvg();
                ratingDeviations.add(deviation);
            }

            Map<String, StatDTO> genreAverages = new HashMap<>();
            for (String genre : genres) {
                genreAverages.put(genre, statRepository.getGenreAverageScores(genre));
            }

            // EXPECTED_GENRES 리스트
            if (review.getMyViolenceScore() != null) {
                genres.stream()
                    .filter(VIOLENCE_EXPECTED_GENRES::contains)
                    .findFirst()
                    .ifPresent(matchedGenre -> {
                        StatDTO avg = genreAverages.get(matchedGenre);
                        if (avg != null) {
                            violenceDeviations.add(review.getMyViolenceScore() - avg.getGenreViolenceScoreAvg());
                        }
                    });
            }
            if (review.getMyHorrorScore() != null) {
                genres.stream()
                    .filter(HORROR_EXPECTED_GENRES::contains) 
                    .findFirst()
                    .ifPresent(matchedGenre -> {
                        StatDTO avg = genreAverages.get(matchedGenre);
                        if (avg != null) {
                            horrorDeviations.add(review.getMyHorrorScore() - avg.getGenreHorrorScoreAvg());
                        }
                    });
            }
            if (review.getMySexualScore() != null) {
                 genres.stream()
                    .filter(SEXUAL_EXPECTED_GENRES::contains) 
                    .findFirst()
                    .ifPresent(matchedGenre -> {
                        StatDTO avg = genreAverages.get(matchedGenre);
                        if (avg != null) {
                            sexualDeviations.add(review.getMySexualScore() - avg.getGenreSexualScoreAvg());
                        }
                    });
            }
        }

        Map<String, Double> finalDeviationScores = new HashMap<>();
        finalDeviationScores.put("작품성", ratingDeviations.stream().mapToDouble(d -> d).average().orElse(0.0));
        finalDeviationScores.put("액션", violenceDeviations.stream().mapToDouble(d -> d).average().orElse(0.0));
        finalDeviationScores.put("스릴", horrorDeviations.stream().mapToDouble(d -> d).average().orElse(0.0));
        finalDeviationScores.put("감성", sexualDeviations.stream().mapToDouble(d -> d).average().orElse(0.0));

        return finalDeviationScores;
    }

    private double calculateAverage(List<Double> numbers) {
        if (numbers == null || numbers.isEmpty()) {
            return 0.0;
        }
        double sum = 0.0;
        for (Double number : numbers) {
            sum = sum + number;
        }
        return sum / numbers.size();
    }
}
