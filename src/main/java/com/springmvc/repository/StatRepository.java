package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.StatDTO;

@Repository
public class StatRepository {
	
	@Autowired
    private JdbcTemplate jdbcTemplate;

    // RowMapper를 재사용하기 위해 멤버 변수로 정의
    private final RowMapper<StatDTO> genreAvgRowMapper = new RowMapper<StatDTO>() {
        @Override
        public StatDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            StatDTO dto = new StatDTO();
            // 쿼리 결과에서 COALESCE를 사용하여 NULL을 0으로 처리했으므로, getDouble/getInt 사용
            dto.setGenreRatingAvg(rs.getDouble("avg_rating"));
            dto.setGenreViolenceScoreAvg(rs.getDouble("avg_violence"));
            dto.setGenreHorrorScoreAvg(rs.getDouble("avg_horror"));
            dto.setGenreSexualScoreAvg(rs.getDouble("avg_sexual"));
            return dto;
        }
    };
    
    // 1. 특정 영화의 장르 목록 가져오기
    public List<String> findGenresByMovieId(long movieId) {
        String sql = "SELECT genre FROM movie_genres WHERE movie_id = ?";
        return jdbcTemplate.queryForList(sql, String.class, movieId);
    }
    
    // 2. 특정 영화의 기본 정보 및 통계 가져오기 (두 테이블 JOIN)
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


    // 3. 특정 장르의 평균 점수 계산하기
    public StatDTO getGenreAverageScores(String genre) {
        String sql = "SELECT " +
                     "    COALESCE(AVG(m.rating), 0.0) as avg_rating, " +
                     "    COALESCE(AVG(m.violence_score_avg), 0.0) as avg_violence, " +
                     "    COALESCE(AVG(ms.horror_score_avg), 0.0) as avg_horror, " +
                     "    COALESCE(AVG(ms.sexual_score_avg), 0.0) as avg_sexual " +
                     "FROM movies m " +
                     "JOIN movie_genres mg ON m.id = mg.movie_id " +
                     "LEFT JOIN movie_stats ms ON m.id = ms.movie_id " +
                     "WHERE mg.genre = ?";
        
        // queryForObject는 결과가 정확히 하나일 때 사용
        return jdbcTemplate.queryForObject(sql, genreAvgRowMapper, genre);
    }
}
