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
        // --- 1. 데이터 수집 ---
        StatDTO movieStats = statRepository.findMovieStatsById(movieId);
        if (movieStats == null) {
            return Collections.singletonList(new InsightMessage("영화 정보를 찾을 수 없습니다."));
        }

        List<String> genres = statRepository.findGenresByMovieId(movieId);
        if (genres.isEmpty()) {
            return Collections.emptyList(); // 장르가 없으면 분석 불가
        }

        // --- 2. 모든 장르에 대해 분석 수행 및 편차 계산 ---
        List<AnalyzedFact> allFacts = new ArrayList<>();

        for (String genre : genres) {
            StatDTO genreAvgStats = statRepository.getGenreAverageScores(genre);

            // 분석 항목 1: 만족도 (rating)
            double ratingDiff = calculateDifference(movieStats.getUserRatingAvg(), genreAvgStats.getGenreRatingAvg());
            if (Math.abs(ratingDiff) > 0.1) {
                String msg = String.format("'%s' 장르 팬들 사이에서 만족도가 평균보다 약 %.0f%% %s 평가를 받고 있습니다.",
                        genre, Math.abs(ratingDiff * 100), ratingDiff > 0 ? "높은" : "낮은");
                allFacts.add(new AnalyzedFact(msg, Math.abs(ratingDiff)));
            }

            // 분석 항목 2: 폭력성 (violence)
            double violenceDiff = calculateDifference(movieStats.getViolenceScoreAvg(), genreAvgStats.getGenreViolenceScoreAvg());
            if (Math.abs(violenceDiff) > 0.2) {
                String msg = String.format("'%s' 장르중에선 폭력성 지수가 평균보다 %.0f%% %s,",
                        genre, Math.abs(violenceDiff * 100), violenceDiff > 0 ? "높아요." : "낮아요.");
                allFacts.add(new AnalyzedFact(msg, Math.abs(violenceDiff)));
            }

            // 분석 항목 3: 공포 (horror)
            double horrorDiff = calculateDifference(movieStats.getHorrorScoreAvg(), genreAvgStats.getGenreHorrorScoreAvg());
            if (Math.abs(horrorDiff) > 0.2) {
                String msg = String.format("이 영화는 '%s' 장르임에도 공포 지수가 평균보다 %.0f%% %s 특별한 경험을 제공합니다.",
                        genre, Math.abs(horrorDiff * 100), horrorDiff > 0 ? "높아" : "낮아");
                allFacts.add(new AnalyzedFact(msg, Math.abs(horrorDiff)));
            }

            // 분석 항목 4: 선정성 (sexual)
            double sexualDiff = calculateDifference(movieStats.getSexualScoreAvg(), genreAvgStats.getGenreSexualScoreAvg());
            if (Math.abs(sexualDiff) > 0.2) {
                String msg = String.format("선정성 지수가 '%s' 장르 평균보다 %.0f%% %s, 이는 %s.",
                        genre, Math.abs(sexualDiff * 100), sexualDiff > 0 ? "높습니다" : "낮습니다",
                        sexualDiff > 0 ? "자극적인 장면을 기대하는 분들께 어필할 수 있습니다" : "가족과 함께 보기 좋아요");
                allFacts.add(new AnalyzedFact(msg, Math.abs(sexualDiff)));
            }
        }

        // --- 3. 가장 흥미로운 사실 필터링 ---
        // 편차(differenceScore)가 큰 순서대로 내림차순 정렬
        allFacts.sort(Comparator.comparingDouble(AnalyzedFact::getDifferenceScore).reversed());

        // 최종적으로 사용자에게 보여줄 메시지 리스트 생성 (상위 3개만 선택)
        List<InsightMessage> finalInsights = new ArrayList<>();
        int maxInsights = 3;
        for (int i = 0; i < Math.min(maxInsights, allFacts.size()); i++) {
            finalInsights.add(new InsightMessage(allFacts.get(i).getMessage()));
        }

        // 리뷰 수가 적을 경우, 신뢰도에 대한 안내 메시지를 가장 앞에 추가
        if (movieStats.getReviewCount() < 5 && movieStats.getReviewCount() > 0) {
            finalInsights.add(0, new InsightMessage("아직 리뷰가 적어 통계 정보는 참고용으로만 활용해 주세요."));
        }

        return finalInsights;
    }
}