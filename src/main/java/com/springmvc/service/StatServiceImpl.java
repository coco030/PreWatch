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
   
    // 내부에서 사용할 메시지 객체 (외부에서 참조할 수 있도록 public으로 유지)
    public static class InsightMessage {
        private String message;
        public InsightMessage(String message) { this.message = message; }
        public String getMessage() { return message; }
    }
    
    // 분석 결과를 담을 내부 클래스 (private으로 변경하여 이 클래스 내에서만 사용)
    private static class AnalyzedFact {
        private String message;
        private double differenceScore;

        public AnalyzedFact(String message, double differenceScore) {
            this.message = message;
            this.differenceScore = differenceScore;
        }

        public String getMessage() {
            return message;
        }

        public double getDifferenceScore() {
            return differenceScore;
        }
    }
    
    // 편차 계산을 위한 헬퍼 메소드
    private double calculateDifference(double movieScore, double genreAvgScore) {
        if (genreAvgScore == 0) {
            return 0.0;
        }
        return (movieScore - genreAvgScore) / genreAvgScore;
    }

    @Override
    public List<InsightMessage> generateInsights(long movieId) {
        // --- 1. 데이터 수집 (기존과 동일) ---
        StatDTO movieStats = statRepository.findMovieStatsById(movieId);
        if (movieStats == null) { return Collections.singletonList(new InsightMessage("영화 정보를 분석할 수 없습니다.")); }
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        if (genres.isEmpty()) { return Collections.emptyList(); }

        // --- 2. 분석 단계 ---

        // [KEY: 분석 유형 코드, VALUE: 해당하는 장르 목록]
        // 이 맵에 분석 결과를 그룹화하여 저장합니다.
        Map<String, List<String>> analysisMap = new HashMap<>();
        
        // 분석 결과를 담을 최종 리스트
        List<AnalyzedFact> allFacts = new ArrayList<>();

        // --- 2-1. 단일 지표 분석 (장르별로 반복하며 그룹화) ---
        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);

            // 분석 A: 만족도가 장르 평균보다 월등히 높은 경우
            if (calculateDifference(movieStats.getUserRatingAvg(), genreAvgStats.getGenreRatingAvg()) > 0.25) { // 25% 이상
                analysisMap.computeIfAbsent("HIGH_RATING", k -> new ArrayList<>()).add(genre);
            }

            // 분석 B: 폭력성 지수가 장르 평균보다 월등히 높은 경우
            if (calculateDifference(movieStats.getViolenceScoreAvg(), genreAvgStats.getGenreViolenceScoreAvg()) > 0.8) { // 80% 이상
                analysisMap.computeIfAbsent("HIGH_VIOLENCE", k -> new ArrayList<>()).add(genre);
            }
            
            // 분석 C: 공포 지수가 장르 평균보다 월등히 높은 경우
            if (calculateDifference(movieStats.getHorrorScoreAvg(), genreAvgStats.getGenreHorrorScoreAvg()) > 1.2) { // 120% 이상
                analysisMap.computeIfAbsent("HIGH_HORROR", k -> new ArrayList<>()).add(genre);
            }
        }

        // --- 2-2. 다중 지표 교차 분석 (영화 전체의 특성으로 한 번만 수행) ---
        String primaryGenre = genres.get(0);
        StatDTO primaryGenreAvg = statRepository.getGenreAverageScores(primaryGenre);

        double violenceDiff = calculateDifference(movieStats.getViolenceScoreAvg(), primaryGenreAvg.getGenreViolenceScoreAvg());
        double sexualDiff = calculateDifference(movieStats.getSexualScoreAvg(), primaryGenreAvg.getGenreSexualScoreAvg());
        
        // CASE 1: 높은 폭력성 + 낮은 선정성
        if (violenceDiff > 0.3 && sexualDiff < -0.4) {
            String msg = "폭력성 지표는 높게 나타나지만 선정성 지표는 낮아, 자극적 묘사 없이 액션 자체에 집중한 연출로 보입니다.";
            allFacts.add(new AnalyzedFact(msg, Math.abs(violenceDiff) + Math.abs(sexualDiff)));
        }
        
        // CASE 2: 높은 폭력성 + 높은 선정성
        if (violenceDiff > 0.5 && sexualDiff > 0.5) {
            String msg = "폭력성과 선정성 지표가 모두 높게 기록되어, 성인 관객층을 겨냥한 강렬한 연출이 특징입니다.";
            allFacts.add(new AnalyzedFact(msg, violenceDiff + sexualDiff));
        }


        // --- 3. 그룹화된 분석 결과를 바탕으로 최종 메시지 조립 ---
        for (Map.Entry<String, List<String>> entry : analysisMap.entrySet()) {
            String analysisCode = entry.getKey();
            List<String> matchedGenres = entry.getValue();

            if (matchedGenres.isEmpty()) continue;

            // 장르 목록을 "'액션', '어드벤처'" 와 같은 문자열로 변환
            String genreListStr = "'" + String.join("', '", matchedGenres) + "'";
            String msg = "";

            switch (analysisCode) {
                case "HIGH_RATING":
                    msg = String.format("만족도 지수가 %s 장르의 평균치보다 눈에 띄게 높아요.", genreListStr);
                    allFacts.add(new AnalyzedFact(msg, 0.8)); // 중요도 점수 부여
                    break;
                case "HIGH_VIOLENCE":
                    msg = String.format("%s 장르의 평균과 비교했을 때, 폭력성 지수가 이례적으로 높은 수치를 기록했습니다.", genreListStr);
                    allFacts.add(new AnalyzedFact(msg, 1.0));
                    break;
                case "HIGH_HORROR":
                    // 대표 장르가 공포/스릴러가 아닌데 공포가 높으면 '의외성' 강조
                    if (!primaryGenre.equals("Horror") && !primaryGenre.equals("Thriller")) {
                         msg = String.format("'%s'이 대표 장르임에도, 공포 지수가 %s 장르 평균보다 현저히 높아 예상치 못한 긴장감을 유발합니다.", primaryGenre, genreListStr);
                    } else {
                         msg = String.format("공포 지수가 %s 장르의 평균치를 크게 상회하여, 극도의 스릴을 제공하는 데 중점을 둔 것으로 보입니다.", genreListStr);
                    }
                    allFacts.add(new AnalyzedFact(msg, 1.2));
                    break;
            }
        }

        // --- 4. 최종 메시지 필터링 및 반환 ---
        // 중요도(differenceScore)가 높은 순서대로 정렬
        allFacts.sort(Comparator.comparingDouble(AnalyzedFact::getDifferenceScore).reversed());

        // 상위 2개의 가장 의미있는 메시지만 선택
        List<InsightMessage> finalInsights = new ArrayList<>();
        int maxInsights = 2;
        for (int i = 0; i < Math.min(maxInsights, allFacts.size()); i++) {
            finalInsights.add(new InsightMessage(allFacts.get(i).getMessage()));
        }

        return finalInsights;
    }
}