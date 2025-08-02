package com.springmvc.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.springmvc.domain.StatDTO;
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

        return statRepository.findSimilarMoviesWithGenres(
            stat.getUserRatingAvg(),       // 만족도
            stat.getViolenceScoreAvg(),    // 폭력성
            stat.getHorrorScoreAvg(),      // 공포성
            stat.getSexualScoreAvg(),      // 선정성
            genres,                        // 기준 영화 장르 리스트
            allowedRatings,                // 허용된 등급 리스트
            movieId                        // 기준 영화 ID
        );
    }


}
