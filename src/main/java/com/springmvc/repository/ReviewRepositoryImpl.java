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

       //(8/5 추가)
        String sql = "SELECT " +
                "    ur.id AS reviewId, " +       
                "    ur.member_id AS memberId, " + 
                "    ur.user_rating AS userRating, " +
                "    mov.id AS movieId, " +       
                "    mov.title AS movieName, " +
                "    ur.review_content AS reviewContent, " +
                "    mov.poster_path AS posterPath, " +
                "    mov.like_count AS newLikeCount " +
                "FROM " +
                "    user_reviews ur " +
                "JOIN " +
                "    member m ON ur.member_id = m.id " +
                "JOIN " +
                "    movies mov ON ur.movie_id = mov.id " +
                "WHERE ur.review_content IS NOT NULL AND ur.review_content != '' " +
                "ORDER BY " +
                "    ur.created_at DESC " +
                "LIMIT 3";
   List<RecentCommentDTO> comments = jdbcTemplate.query(sql, new RecentCommentRowMapper());
   logger.debug("ReviewRepositoryImpl.findTop3RecentComments() 조회 결과: {}개의 코멘트 발견.", comments.size());
   return comments;
}

//(8/5 추가)
@Override
public List<RecentCommentDTO> findAllRecentCommentsWithDetails(int offset, int limit, String sortBy, String sortDirection, String searchType, String keyword) {
   logger.debug("findAllRecentCommentsWithDetails 호출 - offset: {}, limit: {}, sortBy: {}, searchType: {}, keyword: {}", offset, limit, sortBy, searchType, keyword);

   StringBuilder sqlBuilder = new StringBuilder();
   sqlBuilder.append("SELECT ur.id AS reviewId, ur.member_id AS memberId, ur.user_rating AS userRating, ");
   sqlBuilder.append("ur.review_content AS reviewContent, mov.id AS movieId, mov.title AS movieName, mov.poster_path AS posterPath, mov.like_count AS newLikeCount ");
   sqlBuilder.append("FROM user_reviews ur ");
   sqlBuilder.append("JOIN movies mov ON ur.movie_id = mov.id ");
   sqlBuilder.append("WHERE ur.review_content IS NOT NULL AND ur.review_content != '' ");

   String likeKeyword = "%" + keyword + "%";
   
   // 검색 조건 추가
   if (keyword != null && !keyword.trim().isEmpty()) {
       switch (searchType) {
           case "title":
               sqlBuilder.append("AND mov.title LIKE ? ");
               break;
           case "content":
               sqlBuilder.append("AND ur.review_content LIKE ? ");
               break;
           case "writer":
               sqlBuilder.append("AND ur.member_id LIKE ? ");
               break;
           case "all":
           default:
               sqlBuilder.append("AND (mov.title LIKE ? OR ur.review_content LIKE ? OR ur.member_id LIKE ?) ");
               break;
       }
   }

   // 정렬 조건 추가
   String orderByClause;
   switch (sortBy) {
       case "like":
           orderByClause = "ORDER BY newLikeCount " + sortDirection;
           break;
       case "rating":
           orderByClause = "ORDER BY ur.user_rating " + sortDirection;
           break;
       case "date":
       default:
           orderByClause = "ORDER BY ur.created_at " + sortDirection;
           break;
   }
   sqlBuilder.append(orderByClause);
   sqlBuilder.append(" LIMIT ? OFFSET ?");

   String sql = sqlBuilder.toString();
   
   // 파라미터 바인딩
   Object[] params;
   if (keyword != null && !keyword.trim().isEmpty()) {
       if (searchType.equals("all")) {
           params = new Object[]{likeKeyword, likeKeyword, likeKeyword, limit, offset};
       } else {
           params = new Object[]{likeKeyword, limit, offset};
       }
   } else {
       params = new Object[]{limit, offset};
   }

   return jdbcTemplate.query(sql, new RecentCommentRowMapper(), params);
}

@Override
public int countAllComments(String searchType, String keyword) {
   StringBuilder sqlBuilder = new StringBuilder();
   sqlBuilder.append("SELECT COUNT(*) FROM user_reviews ur ");
   sqlBuilder.append("JOIN movies mov ON ur.movie_id = mov.id ");
   sqlBuilder.append("WHERE ur.review_content IS NOT NULL AND ur.review_content != '' ");

   String likeKeyword = "%" + keyword + "%";

   if (keyword != null && !keyword.trim().isEmpty()) {
       switch (searchType) {
           case "title":
               sqlBuilder.append("AND mov.title LIKE ?");
               break;
           case "content":
               sqlBuilder.append("AND ur.review_content LIKE ?");
               break;
           case "writer":
               sqlBuilder.append("AND ur.member_id LIKE ?");
               break;
           case "all":
           default:
               sqlBuilder.append("AND (mov.title LIKE ? OR ur.review_content LIKE ? OR ur.member_id LIKE ?)");
               break;
       }
   }

   String sql = sqlBuilder.toString();
   if (keyword != null && !keyword.trim().isEmpty()) {
       if (searchType.equals("all")) {
           return jdbcTemplate.queryForObject(sql, Integer.class, likeKeyword, likeKeyword, likeKeyword);
       } else {
           return jdbcTemplate.queryForObject(sql, Integer.class, likeKeyword);
       }
   } else {
       return jdbcTemplate.queryForObject(sql, Integer.class);
   }
}

private static class RecentCommentRowMapper implements RowMapper<RecentCommentDTO> {
   @Override
   public RecentCommentDTO mapRow(ResultSet rs, int rowNum) throws SQLException {
       RecentCommentDTO dto = new RecentCommentDTO();
       dto.setReviewId(rs.getLong("reviewId"));
       dto.setMovieId(rs.getLong("movieId"));
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