package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.StatDTO;
import com.springmvc.domain.TasteAnalysisDataDTO;
import com.springmvc.domain.UserReviewScoreDTO;

@Repository
public class StatRepository {
	
	 @Autowired
	 private NamedParameterJdbcTemplate namedParameterJdbcTemplate;
	 
	@Autowired
    private JdbcTemplate jdbcTemplate;

	private final RowMapper<StatDTO> genreAvgRowMapper = new RowMapper<StatDTO>() {
	    @Override
	    public StatDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
	        StatDTO dto = new StatDTO();
	        dto.setGenres(Collections.singletonList(rs.getString("genre"))); // 장르 정보
	        dto.setGenreRatingAvg(rs.getDouble("avg_rating"));               // 작품성 평균
	        dto.setGenreViolenceScoreAvg(rs.getDouble("avg_violence"));      // 폭력성 평균
	        dto.setGenreHorrorScoreAvg(rs.getDouble("avg_horror"));          // 공포성 평균
	        dto.setGenreSexualScoreAvg(rs.getDouble("avg_sexual"));          // 선정성 평균
	        return dto;
	    }
	};
    
    // 1. 특정 영화의 장르 목록 가져오기
    public List<String> findGenresByMovieId(long movieId) {
        String sql = "SELECT genre FROM movie_genres WHERE movie_id = ?";
        return jdbcTemplate.queryForList(sql, String.class, movieId);
    }

    // 2. 특정 영화의 기본 정보 및 통계 가져오기 (두 테이블 JOIN)

    public StatDTO findMovieStatsById(long movieId) {
        String sql = "SELECT " +
                "    m.id, " +
                "    m.title, " +
                "    m.rating, " +
                "    m.violence_score_avg, " +
                "    m.rated, " + // 영화 등급 추가
                "    ms.horror_score_avg, " +
                "    ms.sexual_score_avg, " +
                "    ms.review_count " +
                "FROM movies m " +
                "LEFT JOIN movie_stats ms ON m.id = ms.movie_id " +
                "WHERE m.id = ?";

        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                StatDTO dto = new StatDTO();
                dto.setMovieId(rs.getLong("id"));
                dto.setTitle(rs.getString("title"));
                dto.setUserRatingAvg(rs.getDouble("rating"));
                dto.setViolenceScoreAvg(rs.getDouble("violence_score_avg"));
                dto.setRated(rs.getString("rated")); // rated 세팅
                dto.setHorrorScoreAvg(rs.getDouble("horror_score_avg"));
                if (rs.wasNull()) dto.setHorrorScoreAvg(0.0);
                dto.setSexualScoreAvg(rs.getDouble("sexual_score_avg"));
                if (rs.wasNull()) dto.setSexualScoreAvg(0.0);
                dto.setReviewCount(rs.getInt("review_count"));
                if (rs.wasNull()) dto.setReviewCount(0);
                return dto;
            }, movieId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null; // 영화가 존재하지 않는 경우
        }
    }


 // 3. 특정 장르의 평균 점수 계산하기 - 전체 필드 출력
    public StatDTO getGenreAverageScores(String genre) {
        String sql = "SELECT " +
                     "    mg.genre AS genre, " +  
                     "    COALESCE(AVG(m.rating), 0.0) as avg_rating, " +
                     "    COALESCE(AVG(m.violence_score_avg), 0.0) as avg_violence, " +
                     "    COALESCE(AVG(ms.horror_score_avg), 0.0) as avg_horror, " +
                     "    COALESCE(AVG(ms.sexual_score_avg), 0.0) as avg_sexual " +
                     "FROM movies m " +
                     "JOIN movie_genres mg ON m.id = mg.movie_id " +
                     "LEFT JOIN movie_stats ms ON m.id = ms.movie_id " +
                     "WHERE mg.genre = ? " +
                     "GROUP BY mg.genre";

        return jdbcTemplate.queryForObject(sql, genreAvgRowMapper, genre);
    }

    

    // 유저 상세 점수 분석
    public List<UserReviewScoreDTO> findUserReviewScoresForAnalysis(String memberId) {
        String sql = "SELECT " +
                     "    user_rating as userRating, " +
                     "    violence_score as violenceScore, " +
                     "    horror_score as horrorScore, " +
                     "    sexual_score as sexualScore " +
                     "FROM user_reviews " +
                     "WHERE member_id = :memberId";

        Map<String, String> params = Collections.singletonMap("memberId", memberId);
        
        return namedParameterJdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(UserReviewScoreDTO.class));
    }
    
    // 유저 상세 프로필 
    public List<TasteAnalysisDataDTO> findTasteAnalysisData(String memberId) {
        String sql = "SELECT " +
                     "    ur.user_rating AS myUserRating, " +
                     "    ur.violence_score AS myViolenceScore, " +
                     "    ur.horror_score AS myHorrorScore, " +
                     "    ur.sexual_score AS mySexualScore, " +
                     "    m.rating AS movieAvgRating, " +
                     "    m.violence_score_avg AS movieAvgViolence, " +
                     "    ms.horror_score_avg AS movieAvgHorror, " +
                     "    ms.sexual_score_avg AS movieAvgSexual " +
                     "FROM user_reviews ur " +
                     "JOIN movies m ON ur.movie_id = m.id " +
                     "LEFT JOIN movie_stats ms ON ur.movie_id = ms.movie_id " +
                     "WHERE ur.member_id = :memberId AND ur.user_rating IS NOT NULL";
        
        Map<String, String> params = Collections.singletonMap("memberId", memberId);
        return namedParameterJdbcTemplate.query(sql, params, new BeanPropertyRowMapper<>(TasteAnalysisDataDTO.class));

    }
    
    
    
    public List<StatDTO> findSimilarMoviesWithGenres(
            double userRatingAvg,
            double violenceScoreAvg,
            double horrorScoreAvg,
            double sexualScoreAvg,
            List<String> genres,
            List<String> allowedRatings,
            long baseMovieId) {

       // 장르가 하나 이상일 경우에만 추천 (리포지토리에서 처리)
       if (genres.isEmpty()) {
           return Collections.emptyList();  // 장르가 없으면 빈 리스트 반환
       }

       // IN 절을 위한 placeholder 생성
       String genrePlaceholders = String.join(",", Collections.nCopies(genres.size(), "?"));
       String ratedPlaceholders = String.join(",", Collections.nCopies(allowedRatings.size(), "?"));

       String sql = "SELECT m.id AS movie_id, m.title, m.rated, m.rating, m.violence_score_avg, " +
               "       s.horror_score_avg, s.sexual_score_avg, m.poster_path, " +  // poster_path 추가
               "       SUM(CASE WHEN mg.genre IN (" + genrePlaceholders + ") THEN 1 ELSE 0 END) AS genre_match_count, " +
               "       (ABS(IFNULL(m.rating, 0) - ?) + " +
               "        ABS(IFNULL(m.violence_score_avg, 0) - ?) + " +
               "        ABS(IFNULL(s.horror_score_avg, 0) - ?) + " +
               "        ABS(IFNULL(s.sexual_score_avg, 0) - ?)) AS total_score_diff " +
               "FROM movies m " +
               "LEFT JOIN movie_stats s ON m.id = s.movie_id " +
               "JOIN movie_genres mg ON m.id = mg.movie_id " +
               "WHERE m.id != ? " +
               "  AND m.rated IN (" + ratedPlaceholders + ") " +
               "GROUP BY m.id, m.title, m.rated, m.rating, m.violence_score_avg, s.horror_score_avg, s.sexual_score_avg " +
               "HAVING genre_match_count >= 1 " + // 장르가 하나라도 겹치면 포함
               "ORDER BY genre_match_count DESC, total_score_diff ASC " +
               "LIMIT 10";

       List<Object> params = new ArrayList<>();
       params.addAll(genres);             // 장르 매칭
       params.add(userRatingAvg);         // 평가지표
       params.add(violenceScoreAvg);
       params.add(horrorScoreAvg);
       params.add(sexualScoreAvg);
       params.add(baseMovieId);           // 기준 영화 제외
       params.addAll(allowedRatings);     // 허용 등급

       return jdbcTemplate.query(sql, params.toArray(), (rs, rowNum) -> {
           StatDTO dto = new StatDTO();
           dto.setMovieId(rs.getLong("movie_id"));
           dto.setTitle(rs.getString("title"));
           dto.setRated(rs.getString("rated"));
           dto.setUserRatingAvg(rs.getDouble("rating"));
           dto.setViolenceScoreAvg(rs.getDouble("violence_score_avg"));
           dto.setHorrorScoreAvg(rs.getDouble("horror_score_avg"));
           dto.setSexualScoreAvg(rs.getDouble("sexual_score_avg"));
           dto.setPosterPath(rs.getString("poster_path")); 
           return dto;
       });
   }

    
}

