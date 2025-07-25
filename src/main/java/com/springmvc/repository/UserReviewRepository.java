package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.UserReview;

@Repository
public class UserReviewRepository {
	
	// 장르를 나누기 위한 상수 추가
	private static final List<String> GENRES = List.of(
		    "Action", "Adventure", "Animation", "Biography", "Comedy", "Crime", "Documentary",
		    "Drama", "Family", "Fantasy", "Film-Noir", "History", "Horror", "Music", "Musical",
		    "Mystery", "Romance", "Sci-Fi", "Sport", "Thriller", "War", "Western", "Reality-TV", "Game-Show"
		);

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
    
    // 폭력성 점수만 저장/수정 (중복 시 update)
    public void saveOrUpdateViolenceScore(String memberId, Long movieId, int violenceScore) {
        String sql = "INSERT INTO user_reviews (member_id, movie_id, violence_score) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE violence_score = VALUES(violence_score)";
        jdbcTemplate.update(sql, memberId, movieId, violenceScore);
    }




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

    // 리뷰 내용 저장 또는 수정
    public void saveOrUpdateReviewContent(String memberId, Long movieId, String reviewContent) {
        System.out.println("▶ 리뷰 내용 저장 요청: memberId=" + memberId + ", movieId=" + movieId + ", reviewContent=" + reviewContent);

        String sql = "INSERT INTO user_reviews (member_id, movie_id, review_content) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE review_content = VALUES(review_content)";

        jdbcTemplate.update(sql, memberId, movieId, reviewContent);

        System.out.println("▶ 리뷰 내용 저장 완료");
    }

    // 태그 저장 또는 수정
    public void saveOrUpdateTag(String memberId, Long movieId, String tag) {
        System.out.println("▶ 태그 저장 요청: memberId=" + memberId + ", movieId=" + movieId + ", tags=" + tag);

        String sql = "INSERT INTO user_reviews (member_id, movie_id, tags) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE tags = VALUES(tags)";

        jdbcTemplate.update(sql, memberId, movieId, tag);

        System.out.println("▶ 태그 저장 완료");
    }

    public int getTotalReviewCount(String memberId) {
    	System.out.println("▶ 모든 마이 페이지의 리뷰 세어보기 완료");
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE member_id = ?";
        return jdbcTemplate.queryForObject(sql, Integer.class, memberId);
    }

    public List<UserReview> getPagedReviews(String memberId, int page, int pageSize) {
    	System.out.println("▶ 마이 페이지의 리뷰 세어보기 완료");
    	int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM user_reviews WHERE member_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, new Object[]{memberId, pageSize, offset}, (rs, rowNum) -> {
            UserReview review = new UserReview();
            review.setId(rs.getLong("id"));
            review.setMemberId(rs.getString("member_id"));
            review.setMovieId(rs.getLong("movie_id"));
            review.setUserRating(rs.getObject("user_rating") != null ? rs.getInt("user_rating") : null);
            review.setViolenceScore(rs.getObject("violence_score") != null ? rs.getInt("violence_score") : null);
            review.setReviewContent(rs.getString("review_content"));
            review.setTags(rs.getString("tags"));
            review.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return review;
        });
    }
    
    // 유저 리뷰 삭제하기
    public boolean deleteByMemberIdAndMovieId(String memberId, Long movieId) {
        String sql = "DELETE FROM user_reviews WHERE member_id = ? AND movie_id = ?";
        int rowsAffected = jdbcTemplate.update(sql, memberId, movieId);
        return rowsAffected > 0;
    }
    
    
    // 한 유저 대상. 유저가 자주 평가한 장르 장르별 평가 수 집계 25.07.25 오전 10시부터 작업
    public Map<String, Integer> getGenreCountsByMemberId(String memberId) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT ");
        for (int i = 0; i < GENRES.size(); i++) {
            String genre = GENRES.get(i);
            String alias = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_count";
            sqlBuilder.append("SUM(CASE WHEN LOWER(m.genre) LIKE '%")
                      .append(genre.toLowerCase())
                      .append("%' THEN 1 ELSE 0 END) AS ")
                      .append(alias);
            if (i < GENRES.size() - 1) sqlBuilder.append(", ");
        }
        sqlBuilder.append(" FROM user_reviews ur JOIN movies m ON ur.movie_id = m.id WHERE ur.member_id = ?");

        String sql = sqlBuilder.toString();
        return jdbcTemplate.query(sql, rs -> {
            Map<String, Integer> genreCounts = new java.util.HashMap<>();
            if (rs.next()) {
                for (String genre : GENRES) {
                    String key = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_count";
                    genreCounts.put(genre, rs.getInt(key));
                }
            }
            return genreCounts;
        }, memberId);
    }

    
    // 한 유저의 장르별 긍정 평가 수 (8점 이상 기준)  25.07.25 오전 10시부터 작업하고 오전 11시 40분 완료
    public Map<String, Integer> getPositiveRatingGenreCounts(String memberId) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT ");
        for (int i = 0; i < GENRES.size(); i++) {
            String genre = GENRES.get(i);
            String alias = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_pos_count";
            sqlBuilder.append("SUM(CASE WHEN LOWER(m.genre) LIKE '%")
                      .append(genre.toLowerCase())
                      .append("%' AND ur.user_rating >= 8 THEN 1 ELSE 0 END) AS ")
                      .append(alias);
            if (i < GENRES.size() - 1) sqlBuilder.append(", ");
        }
        sqlBuilder.append(" FROM user_reviews ur JOIN movies m ON ur.movie_id = m.id WHERE ur.member_id = ?");

        String sql = sqlBuilder.toString();
        return jdbcTemplate.query(sql, rs -> {
            Map<String, Integer> result = new java.util.HashMap<>();
            if (rs.next()) {
                for (String genre : GENRES) {
                    String key = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_pos_count";
                    result.put(genre, rs.getInt(key));
                }
            }
            return result;
        }, memberId);
    }
  // 한 유저의 장르별 부정 평가 수 (4점 이하 기준)
    public Map<String, Integer> getNegativeRatingGenreCounts(String memberId) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT ");
        for (int i = 0; i < GENRES.size(); i++) {
            String genre = GENRES.get(i);
            String alias = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_neg_count";
            sqlBuilder.append("SUM(CASE WHEN LOWER(m.genre) LIKE '%")
                      .append(genre.toLowerCase())
                      .append("%' AND ur.user_rating <= 4 THEN 1 ELSE 0 END) AS ")
                      .append(alias);
            if (i < GENRES.size() - 1) sqlBuilder.append(", ");
        }
        sqlBuilder.append(" FROM user_reviews ur JOIN movies m ON ur.movie_id = m.id WHERE ur.member_id = ?");

        String sql = sqlBuilder.toString();
        return jdbcTemplate.query(sql, rs -> {
            Map<String, Integer> result = new HashMap<>();
            if (rs.next()) {
                for (String genre : GENRES) {
                    String key = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_neg_count";
                    result.put(genre, rs.getInt(key));
                }
            }
            return result;
        }, memberId);
    }

    // 한 유저가 평균 만족도 점수 매긴 것 user_rating
    public Double getAverageUserRatingByMemberId(String memberId) {
        String sql = "SELECT AVG(user_rating) FROM user_reviews WHERE member_id = ? AND user_rating IS NOT NULL";
        return jdbcTemplate.queryForObject(sql, Double.class, memberId);
    }

    // 한 유저가 평균 폭력성 점수 매긴 것 violence_score
    public Double getAverageViolenceScoreByMemberId(String memberId) {
        String sql = "SELECT AVG(violence_score) FROM user_reviews WHERE member_id = ? AND violence_score IS NOT NULL";
        return jdbcTemplate.queryForObject(sql, Double.class, memberId);
    }
    // 한 유저가 user_rating 점수를 남긴 횟수
    public Integer getUserRatingCount(String memberId) {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE member_id = ? AND user_rating IS NOT NULL";
        return jdbcTemplate.queryForObject(sql, Integer.class, memberId);
    }
    // 한 유저가 violence_score를 남긴 횟수
    public Integer getViolenceScoreCount(String memberId) {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE member_id = ? AND violence_score IS NOT NULL";
        return jdbcTemplate.queryForObject(sql, Integer.class, memberId);
    }

    // 한 유저의 ★ 긍정 평가 수 (user_rating ≥ 8)
    public Integer getPositiveRatingTotalCount(String memberId) {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE member_id = ? AND user_rating >= 8";
        return jdbcTemplate.queryForObject(sql, Integer.class, memberId);
    }

    // 한 유저의 ★ 부정 평가 수 (user_rating ≤ 4)
    public Integer getNegativeRatingTotalCount(String memberId) {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE member_id = ? AND user_rating <= 4";
        return jdbcTemplate.queryForObject(sql, Integer.class, memberId);
    }


}
