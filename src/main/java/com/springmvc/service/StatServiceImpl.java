package com.springmvc.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
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
        if (movieStats == null) { /* ... */ }
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        if (genres.isEmpty()) { /* ... */ }

        // --- 2. 분석 및 메시지 생성 ---
        List<AnalyzedFact> allFacts = new ArrayList<>();
        String primaryGenre = genres.get(0);

        // --- 시나리오 1: 액션 영화의 다각도 분석 ---
        if (genres.contains("Action") || genres.contains("Thriller") || genres.contains("Crime")) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores("Action"); // 대표적으로 액션 장르와 비교
            
            double violenceDiff = calculateDifference(movieStats.getViolenceScoreAvg(), genreAvgStats.getGenreViolenceScoreAvg());
            double sexualDiff = calculateDifference(movieStats.getSexualScoreAvg(), genreAvgStats.getGenreSexualScoreAvg());

            // CASE 1-1: 폭력성은 높은데, 선정성은 낮을 때 (온가족 액션)
            if (violenceDiff > 0.3 && sexualDiff < -0.4) {
                String msg = "화려한 액션은 가득하지만 자극적인 장면은 적어서, 온 가족이 함께 즐길 수 있는 액션 영화 같아요.";
                allFacts.add(new AnalyzedFact(msg, Math.abs(violenceDiff) + Math.abs(sexualDiff)));
            }
            
            // CASE 1-2: 폭력성과 선정성 모두 높을 때 (성인 취향 하드코어 액션)
            if (violenceDiff > 0.5 && sexualDiff > 0.5) {
                String msg = "화끈한 액션과 더불어 짜릿한 장면들도 많아서, 성인 관객들의 취향을 저격할 만한 영화네요.";
                allFacts.add(new AnalyzedFact(msg, violenceDiff + sexualDiff));
            }
        }

        // --- 시나리오 2: 코미디 영화의 반전 매력 분석 ---
        if (genres.contains("Comedy")) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores("Comedy");
            
            double horrorDiff = calculateDifference(movieStats.getHorrorScoreAvg(), genreAvgStats.getGenreHorrorScoreAvg());
            double ratingDiff = calculateDifference(movieStats.getUserRatingAvg(), genreAvgStats.getGenreRatingAvg());

            // CASE 2-1: 그냥 웃기기만 한 게 아니라, 공포/스릴까지 잡았을 때
            if (horrorDiff > 1.2 && ratingDiff > 0.1) {
                String msg = "웃음 속에 예상치 못한 서늘함이 숨어 있어서, 색다른 재미를 찾는 분들에게 딱 맞는 코미디일 수 있어요.";
                allFacts.add(new AnalyzedFact(msg, horrorDiff + ratingDiff));
            }
        }

        // --- 시나리오 3: 로맨스 영화의 깊이 분석 ---
        if (genres.contains("Romance")) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores("Romance");

            double ratingDiff = calculateDifference(movieStats.getUserRatingAvg(), genreAvgStats.getGenreRatingAvg());
            double sexualDiff = calculateDifference(movieStats.getSexualScoreAvg(), genreAvgStats.getGenreSexualScoreAvg());

            // CASE 3-1: 높은 만족도, 낮은 선정성 (풋풋하고 순수한 로맨스)
            if (ratingDiff > 0.15 && sexualDiff < -0.3) {
                String msg = "자극적인 장면 없이도 깊은 여운을 남겨서, 풋풋한 설렘을 느끼고 싶을 때 보면 좋을 것 같아요.";
                allFacts.add(new AnalyzedFact(msg, ratingDiff + Math.abs(sexualDiff)));
            }
        }

        // --- 시나리오 4: 모든 장르에 적용 가능한 일반 분석 (개별 지표가 매우 특이할 때) ---
        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);
            double ratingDiff = calculateDifference(movieStats.getUserRatingAvg(), genreAvgStats.getGenreRatingAvg());

            // CASE 4-1: 만족도가 유독 높을 때 (숨겨진 명작)
            if (ratingDiff > 0.35) { // 35% 이상 높으면
                String msg = String.format("특히 '%s' 장르를 좋아하는 분들 사이에서 입소문이 난, 숨겨진 보석 같은 작품이네요.", genre);
                allFacts.add(new AnalyzedFact(msg, ratingDiff));
            }
        }
        
        // --- 3. 최종 메시지 필터링 및 반환 (기존 로직 개선) ---
        // 중복 메시지 제거
        List<AnalyzedFact> uniqueFacts = new ArrayList<>(
            allFacts.stream()
                    .collect(java.util.stream.Collectors.toMap(
                        AnalyzedFact::getMessage, f -> f, (f1, f2) -> f1))
                    .values()
        );

        // 편차(중요도)가 큰 순서대로 정렬
        uniqueFacts.sort(Comparator.comparingDouble(AnalyzedFact::getDifferenceScore).reversed());

        // 상위 2개의 가장 흥미로운 메시지만 선택
        List<InsightMessage> finalInsights = new ArrayList<>();
        int maxInsights = 2;
        for (int i = 0; i < Math.min(maxInsights, uniqueFacts.size()); i++) {
            finalInsights.add(new InsightMessage(uniqueFacts.get(i).getMessage()));
        }

        // 리뷰 수 적을 때 안내 문구 추가
        if (movieStats.getReviewCount() < 5 && movieStats.getReviewCount() > 0) {
            finalInsights.add(0, new InsightMessage("이 영화에 대한 평가는 이제 막 시작되었어요. 첫인상은 어떤지 한번 확인해 보세요."));
        } else if (finalInsights.isEmpty() && movieStats.getReviewCount() > 0) {
            // 분석 결과는 없지만 리뷰는 있을 때
            finalInsights.add(new InsightMessage("이 영화는 아직 뚜렷한 특징이 나타나지 않았어요. 당신의 평가가 새로운 기준이 될 수 있답니다."));
        }

        return finalInsights;
    }
}