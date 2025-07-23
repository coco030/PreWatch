package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.UserReview;

@Repository
public class UserReviewRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<UserReview> rowMapper = new RowMapper<UserReview>() {
        @Override
        public UserReview mapRow(ResultSet rs, int rowNum) throws SQLException {
            UserReview review = new UserReview();
            review.setId(rs.getLong("id"));
            review.setMemberId(rs.getString("member_id"));
            review.setMovieId(rs.getLong("movie_id"));
            review.setUserRating(rs.getInt("user_rating"));
            review.setViolenceScore(rs.getInt("violence_score"));
            review.setReviewContent(rs.getString("review_content"));
            review.setTags(rs.getString("tags"));
            review.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return review;
        }
    };
    
    
    // 별점만 저장/수정 (중복 시 update)
    public void saveOrUpdateRating(String memberId, Long movieId, int userRating) {
        String sql = "INSERT INTO user_reviews (member_id, movie_id, user_rating) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE user_rating = VALUES(user_rating)";
        jdbcTemplate.update(sql, memberId, movieId, userRating);
    }

//    //  리뷰 저장 or 업데이트
//    public void saveOrUpdate(UserReview review) {
//        System.out.println("★ 리뷰 저장 시도: " + review);
//        String sql = "INSERT INTO user_reviews (member_id, movie_id, user_rating, violence_score, review_content, tags) " +
//                     "VALUES (?, ?, ?, ?, ?, ?) " +
//                     "ON DUPLICATE KEY UPDATE " +
//                     "user_rating = VALUES(user_rating), " +
//                     "violence_score = VALUES(violence_score), " +
//                     "review_content = VALUES(review_content), " +
//                     "tags = VALUES(tags)";
//        int result = jdbcTemplate.update(sql,
//                review.getMemberId(),
//                review.getMovieId(),
//                review.getUserRating(),
//                review.getViolenceScore(),
//                review.getReviewContent(),
//                review.getTags()
//        );
//        System.out.println("★ DB 저장 결과: " + result);
//    }
    
    


 // 특정 영화의 전체 리뷰 (최신순)
    public List<UserReview> findByMovieId(Long movieId) {
        System.out.println("▶ 전체 리뷰 조회 실행, movieId: " + movieId);

        String sql = "SELECT * FROM user_reviews WHERE movie_id = ? ORDER BY created_at DESC";
        List<UserReview> list = jdbcTemplate.query(sql, rowMapper, movieId);

        System.out.println("▶ 조회된 리뷰 수: " + list.size());
        if (!list.isEmpty()) {
            System.out.println("▶ 첫 번째 리뷰: " + list.get(0));  // toString() 오버라이드 필요
        }

        return list;
    }

    // 로그인한 사용자의 리뷰 1건
    public UserReview findByMemberIdAndMovieId(String memberId, Long movieId) {
        System.out.println("▶ 특정 사용자 리뷰 조회: memberId=" + memberId + ", movieId=" + movieId);

        String sql = "SELECT * FROM user_reviews WHERE member_id = ? AND movie_id = ?";
        List<UserReview> result = jdbcTemplate.query(sql, rowMapper, memberId, movieId);

        if (result.isEmpty()) {
            System.out.println("▶ 해당 사용자의 리뷰 없음");
            return null;
        } else {
            System.out.println("▶ 해당 사용자의 리뷰 조회됨: " + result.get(0));
            return result.get(0);
        }
    }

    // 평균 별점 계산
    public Double getAverageRating(Long movieId) {
    	System.out.println("▶ 평균 만족도 점수 계산 중... movieId: " + movieId);	
        String sql = "SELECT AVG(user_rating) FROM user_reviews WHERE movie_id = ? AND user_rating IS NOT NULL";
        Double result = jdbcTemplate.queryForObject(sql, Double.class, movieId);
        System.out.println("▶ 계산된 평균 만족도: " + result);
        return result;
        
    }
    
    // 평균 폭력성 점수 계산
    public Double getAverageViolenceScore(Long movieId) {
        System.out.println("▶ 평균 폭력성 점수 계산 중... movieId: " + movieId);    
        String sql = "SELECT AVG(violence_score) FROM user_reviews WHERE movie_id = ? AND violence_score IS NOT NULL";
        Double result = jdbcTemplate.queryForObject(sql, Double.class, movieId);
        System.out.println("▶ 계산된 평균 폭력성 점수: " + result);
        return result;
    }
    
    // 마이페이지에서 사용자가 작성한 모든 리뷰 조회 뷰
    public List<UserReview> findAllByMemberId(String memberId) {
        String sql = "SELECT * FROM user_reviews WHERE member_id = ? ORDER BY created_at DESC";
        return jdbcTemplate.query(sql, rowMapper, memberId);
    }
}
