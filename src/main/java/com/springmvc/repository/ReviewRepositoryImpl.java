// src/main/java/com/springmvc/repository/ReviewRepositoryImpl.java
package com.springmvc.repository;

import com.springmvc.domain.RecentCommentDTO;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.slf4j.Logger; // Logger 임포트
import org.slf4j.LoggerFactory; // LoggerFactory 임포트

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class ReviewRepositoryImpl implements ReviewRepository {

	private static final Logger logger = LoggerFactory.getLogger(ReviewRepositoryImpl.class); // 로거 선언
	
    private final JdbcTemplate jdbcTemplate;

    public ReviewRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<RecentCommentDTO> findTop3RecentComments() {
    	logger.debug("ReviewRepositoryImpl.findTop3RecentComments() 호출: 최근 코멘트 조회 시도.");

        // - 'reviews' 테이블 -> 'user_reviews'
        // - 'members' 테이블 -> 'member'
        // - 'member_id' 컬럼 -> 'id' (member 테이블)
        // - 'movie_name' 컬럼 -> 'title' (movies 테이블)
        // - 'created_at' 컬럼 -> 'created_at' (user_reviews 테이블)
        // - 찜 개수는 'review_likes' 테이블 대신 'movies' 테이블의 'like_count'를 사용합니다.
        String sql = "SELECT " +
                     "    m.id AS memberId, " +          // member 테이블의 'id' 컬럼 사용
                     "    ur.user_rating AS userRating, " +
                     "    mov.title AS movieName, " +     // movies 테이블의 'title' 컬럼 사용
                     "    ur.review_content AS reviewContent, " +
                     "    mov.poster_path AS posterPath, " +
                     "    mov.like_count AS newLikeCount " + // movies 테이블의 'like_count' 컬럼 사용
                     "FROM " +
                     "    user_reviews ur " +             // user_reviews 테이블 사용
                     "JOIN " +
                     "    member m ON ur.member_id = m.id " + // member 테이블의 'id' 컬럼과 조인
                     "JOIN " +
                     "    movies mov ON ur.movie_id = mov.id " +
                     "ORDER BY " +
                     "    ur.created_at DESC " +         // user_reviews 테이블의 'created_at' 컬럼 사용
                     "LIMIT 3";

        List<RecentCommentDTO> comments = jdbcTemplate.query(sql, new RecentCommentRowMapper());
        logger.debug("ReviewRepositoryImpl.findTop3RecentComments() 조회 결과: {}개의 코멘트 발견.", comments.size());
        if (!comments.isEmpty()) {
            comments.forEach(comment -> logger.debug("  - 코멘트: {}", comment.toString())); // 각 코멘트 내용 로깅
        }
        return jdbcTemplate.query(sql, new RecentCommentRowMapper());
    }

    // ResultSet을 RecentCommentDTO 객체로 매핑하는 RowMapper 구현
    private static class RecentCommentRowMapper implements RowMapper<RecentCommentDTO> {
        @Override
        public RecentCommentDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            RecentCommentDTO dto = new RecentCommentDTO();
            dto.setMemberId(rs.getString("memberId"));
            dto.setUserRating(rs.getInt("userRating"));
            dto.setMovieName(rs.getString("movieName"));
            dto.setReviewContent(rs.getString("reviewContent"));
            dto.setPosterPath(rs.getString("posterPath"));
            dto.setNewLikeCount(rs.getInt("newLikeCount"));
            return dto;
        }
    }
}
