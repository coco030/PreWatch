package com.springmvc.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.springmvc.domain.StatDTO;
import com.springmvc.repository.StatRepository;
import com.springmvc.repository.movieRepository;

@Service
public class StatServiceImpl implements StatService {
	

	@Autowired
	private movieRepository movieRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private StatRepository statRepository;

    // 장르 나누기 위함
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
    
    // 장르 나눈 것 끝
   
    // 내부에서 사용할 메시지 객체
    public static class InsightMessage {
        private String message;
        public InsightMessage(String message) { this.message = message; }
        public String getMessage() { return message; }
    }
    
    @Override
    public List<InsightMessage> generateInsights(long movieId) {
        List<InsightMessage> insights = new ArrayList<>();

        // 1. 특정 영화의 모든 통계 데이터 가져오기
        StatDTO movieStats = statRepository.findMovieStatsById(movieId);
        if (movieStats == null) {
            insights.add(new InsightMessage("영화 정보를 찾을 수 없습니다."));
            return insights;
        }
        
        // 리뷰 수가 너무 적으면 통계 신뢰도에 대한 안내 메시지 추가
        if (movieStats.getReviewCount() < 1) {
            insights.add(new InsightMessage("아직 리뷰가 충분히 쌓이지 않아 통계 정보의 정확도가 낮을 수 있습니다."));
        }

        // 2. 영화의 장르 목록 가져오기
        List<String> genres = statRepository.findGenresByMovieId(movieId);
        if (genres.isEmpty()) {
            // 장르가 없으면 비교 불가, 여기서 종료
            return insights;
        }
        movieStats.setGenres(genres);
        
        // 3. 첫 번째 장르를 기준으로 장르 평균 점수 가져오기
        String primaryGenre = genres.get(0);
        StatDTO genreAvgStats = statRepository.getGenreAverageScores(primaryGenre);

        // 4. 데이터 비교 및 메시지 생성
        // 예시 1: 코미디 영화인데 공포 점수가 높은 경우
        if ("Comedy".equals(primaryGenre) && movieStats.getHorrorScoreAvg() > genreAvgStats.getGenreHorrorScoreAvg() * 1.5) {
            String msg = String.format("이 코미디 영화는 동 장르 평균보다 공포 점수가 눈에 띄게 높게 평가되었습니다. 색다른 재미를 원하신다면 추천!");
            insights.add(new InsightMessage(msg));
        }

        // 예시 2: 액션 영화인데 선정성 점수가 낮은 경우
        if ("Action".equals(primaryGenre) && movieStats.getSexualScoreAvg() < genreAvgStats.getGenreSexualScoreAvg() * 0.7) {
             String msg = String.format("이 액션 영화는 선정성 지수가 낮아 가족과 함께 즐기기 좋은 영화로 평가받고 있습니다.");
             insights.add(new InsightMessage(msg));
        }

        // 예시 3: 폭력성 점수가 장르 평균 대비 얼마나 높은지 구체적인 수치로 보여주기
        if (movieStats.getViolenceScoreAvg() > genreAvgStats.getGenreViolenceScoreAvg() && genreAvgStats.getGenreViolenceScoreAvg() > 0) {
            double percentage = (movieStats.getViolenceScoreAvg() / genreAvgStats.getGenreViolenceScoreAvg() - 1) * 100;
            if(percentage > 20) { // 20% 이상 차이날 때만 보여주기
                String msg = String.format("이 영화의 폭력성 지수는 '%s' 장르 평균보다 약 %.0f%% 높습니다. 시청에 참고하세요.", primaryGenre, percentage);
                insights.add(new InsightMessage(msg));
            }
        }
        
        // 등등 비교 더 쓸 수 있음.
        
        return insights;
    }
}

