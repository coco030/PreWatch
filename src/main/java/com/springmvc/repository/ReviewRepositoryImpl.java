// src/main/java/com/springmvc/repository/ReviewRepositoryImpl.java
package com.springmvc.repository;

import com.springmvc.domain.RecentCommentDTO; // RecentCommentDTO 클래스 임포트 확인
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper; // RowMapper 임포트
import org.springframework.stereotype.Repository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class ReviewRepositoryImpl implements ReviewRepository {

    private static final Logger logger = LoggerFactory.getLogger(ReviewRepositoryImpl.class);

    private final JdbcTemplate jdbcTemplate;

    public ReviewRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<RecentCommentDTO> findTop3RecentComments() {
        logger.debug("ReviewRepositoryImpl.findTop3RecentComments() 호출: 최근 코멘트 조회 시도.");

        String sql = "SELECT " +
                     "    ur.id AS reviewId, " +       // ⭐ 리뷰의 ID 추가 (user_reviews 테이블의 id)
                     "    m.id AS memberId, " +        // member 테이블의 'id' 컬럼 (사용자 ID)
                     "    ur.user_rating AS userRating, " +
                     "    mov.id AS movieId, " +       // ⭐ 영화의 ID 추가 (movies 테이블의 id)
                     "    mov.title AS movieName, " +
                     "    ur.review_content AS reviewContent, " +
                     "    mov.poster_path AS posterPath, " +
                     "    mov.like_count AS newLikeCount " + // movies 테이블의 'like_count' 컬럼 사용
                     "FROM " +
                     "    user_reviews ur " +
                     "JOIN " +
                     "    member m ON ur.member_id = m.id " +
                     "JOIN " +
                     "    movies mov ON ur.movie_id = mov.id " +
                     "ORDER BY " +
                     "    ur.created_at DESC " +
                     "LIMIT 3"; // LIMIT 3은 유지하되, 필요에 따라 개수 조절

        List<RecentCommentDTO> comments = jdbcTemplate.query(sql, new RecentCommentRowMapper());

        logger.debug("ReviewRepositoryImpl.findTop3RecentComments() 조회 결과: {}개의 코멘트 발견.", comments.size());
        if (!comments.isEmpty()) {
            comments.forEach(comment -> logger.debug("  - 코멘트: {}", comment.toString())); // 각 코멘트 내용 로깅
        }
        return comments; // 두 번 호출하지 않고, 한 번 조회한 결과를 반환
    }

    // ResultSet을 RecentCommentDTO 객체로 매핑하는 RowMapper 구현
    private static class RecentCommentRowMapper implements RowMapper<RecentCommentDTO> {
        @Override
        public RecentCommentDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
            RecentCommentDTO dto = new RecentCommentDTO();
            // ⭐⭐⭐ 여기 추가 ⭐⭐⭐
            dto.setReviewId(rs.getLong("reviewId")); // SQL에서 AS reviewId로 조회한 값을 매핑
            dto.setMovieId(rs.getLong("movieId"));   // SQL에서 AS movieId로 조회한 값을 매핑
            // ⭐⭐⭐ 추가 끝 ⭐⭐⭐
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