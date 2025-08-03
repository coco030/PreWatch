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
import com.springmvc.service.UserReviewService;

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
    
    @Autowired
    private UserReviewService userReviewService;

    private RowMapper<UserReview> rowMapper = new RowMapper<UserReview>() {
        @Override
        public UserReview mapRow(ResultSet rs, int rowNum) throws SQLException {
            UserReview review = new UserReview();
            review.setId(rs.getLong("id"));
            review.setMemberId(rs.getString("member_id"));
            review.setMovieId(rs.getLong("movie_id"));
            review.setUserRating(rs.getInt("user_rating"));
            review.setViolenceScore(rs.getInt("violence_score"));
            review.setHorrorScore(rs.getInt("horror_score"));       // ✅ 공포성 점수
            review.setSexualScore(rs.getInt("sexual_score"));       // ✅ 선정성 점수
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

    // 마이페이지에 값 넣을 때 여기 수정. 호러/공포 점수 매칭이 안돼서 여기 sql 추가함. 값만 넣고 sql을 안 넣었음.
    public List<UserReview> getPagedReviews(String memberId, int page, int pageSize) {
        System.out.println("▶ 마이 페이지의 리뷰 페이징 조회 실행");
        int offset = (page - 1) * pageSize;

        String sql = "SELECT id, member_id, movie_id, user_rating, violence_score, horror_score, sexual_score, review_content, tags, created_at " +
                     "FROM user_reviews WHERE member_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";

        return jdbcTemplate.query(sql, new Object[]{memberId, pageSize, offset}, (rs, rowNum) -> {
            UserReview review = new UserReview();
            review.setId(rs.getLong("id"));
            review.setMemberId(rs.getString("member_id"));
            review.setMovieId(rs.getLong("movie_id"));
            review.setUserRating(rs.getObject("user_rating") != null ? rs.getInt("user_rating") : null);
            review.setViolenceScore(rs.getObject("violence_score") != null ? rs.getInt("violence_score") : null);
            review.setHorrorScore(rs.getObject("horror_score") != null ? rs.getInt("horror_score") : null); // ✅ 추가됨
            review.setSexualScore(rs.getObject("sexual_score") != null ? rs.getInt("sexual_score") : null); // ✅ 추가됨
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
    // 한 유저의 별점 분포 (히스토그램)  → 1점 ~ 10점에 몇 개씩 줬는지
    public Map<Integer, Integer> getRatingDistribution(String memberId) {
        String sql = "SELECT user_rating, COUNT(*) AS count " +
                     "FROM user_reviews " +
                     "WHERE member_id = ? AND user_rating IS NOT NULL " +
                     "GROUP BY user_rating ORDER BY user_rating";

        return jdbcTemplate.query(sql, rs -> {
            Map<Integer, Integer> ratingCounts = new HashMap<>();
            while (rs.next()) {
                ratingCounts.put(rs.getInt("user_rating"), rs.getInt("count"));
            }
            return ratingCounts;
        }, memberId);
    }

	// 한 유저의 영화 장르별 평균 별점	→ Action 장르엔 평균 몇 점 줬는지
    public Map<String, Double> getGenreAverageRatings(String memberId) {
        StringBuilder sqlBuilder = new StringBuilder("SELECT ");
        for (int i = 0; i < GENRES.size(); i++) {
            String genre = GENRES.get(i);
            String alias = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_avg";
            sqlBuilder.append("AVG(CASE WHEN LOWER(m.genre) LIKE '%")
                      .append(genre.toLowerCase())
                      .append("%' THEN ur.user_rating ELSE NULL END) AS ")
                      .append(alias);
            if (i < GENRES.size() - 1) sqlBuilder.append(", ");
        }
        sqlBuilder.append(" FROM user_reviews ur JOIN movies m ON ur.movie_id = m.id WHERE ur.member_id = ?");

        String sql = sqlBuilder.toString();
        return jdbcTemplate.query(sql, rs -> {
            Map<String, Double> result = new HashMap<>();
            if (rs.next()) {
                for (String genre : GENRES) {
                    String key = genre.toLowerCase().replace("-", "_").replace(" ", "_") + "_avg";
                    result.put(genre, rs.getDouble(key));
                }
            }
            return result;
        }, memberId);
    }

    public boolean updateTags(String memberId, Long movieId, String updatedTags) {
        String sql = "UPDATE user_reviews SET tags = ? WHERE member_id = ? AND movie_id = ?";
        int result = jdbcTemplate.update(sql, updatedTags, memberId, movieId);
        return result > 0;
    }
    

    

    //사이트 전체 리뷰 총 계수
    public long getTotalReviewContentCount() {
        // 내용이 비어있지 않은 리뷰만 카운트합니다.
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE review_content IS NOT NULL AND review_content != ''";
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return (count != null) ? count : 0L;
    }

    // 만족도 점수 총 계수
    public long getTotalUserRatingCount() {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE user_rating IS NOT NULL";
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return (count != null) ? count : 0L;
    }

    // 폭력성 점수 총 계수
    public long getTotalViolenceScoreCount() {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE violence_score IS NOT NULL";
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return (count != null) ? count : 0L;
    }
    
    public long getTotalHorrorScoreCount() {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE horror_score IS NOT NULL";
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return (count != null) ? count : 0L;
    }

    public long getTotalSexualScoreCount() {
        String sql = "SELECT COUNT(*) FROM user_reviews WHERE sexual_score IS NOT NULL";
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return (count != null) ? count : 0L;
    }
    ///

 // ✅ 유저가 평가한 호러 점수 평균 계산 (user_reviews 기준)
    public Double getAverageHorrorScore(Long movieId) {
        System.out.println("▶ [user_reviews] 공포 점수 평균 계산 중... movieId: " + movieId);
        String sql = "SELECT AVG(horror_score) FROM user_reviews WHERE movie_id = ? AND horror_score IS NOT NULL";
        Double result = jdbcTemplate.queryForObject(sql, Double.class, movieId);
        System.out.println("▶ [user_reviews] 계산된 공포 점수 평균: " + result);
        return result;
    }

    // ✅ 유저가 평가한 선정성 점수 평균 계산 (user_reviews 기준)
    public Double getAverageSexualScore(Long movieId) {
        System.out.println("▶ [user_reviews] 선정성 점수 평균 계산 중... movieId: " + movieId);
        String sql = "SELECT AVG(sexual_score) FROM user_reviews WHERE movie_id = ? AND sexual_score IS NOT NULL";
        Double result = jdbcTemplate.queryForObject(sql, Double.class, movieId);
        System.out.println("▶ [user_reviews] 계산된 선정성 점수 평균: " + result);
        return result;
    }

    // ✅ 계산된 평균을 movie_stats 테이블에 반영 (없으면 INSERT)
    public void updateHorrorScoreAvg(Long movieId, double avg) {
        System.out.println("▶ [movie_stats] 공포 점수 평균 업데이트 시도... movieId: " + movieId + ", avg: " + avg);
        String updateSql = "UPDATE movie_stats SET horror_score_avg = ? WHERE movie_id = ?";
        int updated = jdbcTemplate.update(updateSql, avg, movieId);

        if (updated == 0) {
            System.out.println("▶ [movie_stats] 기존 데이터 없음 → 새 행 INSERT 진행");
            String insertSql = "INSERT INTO movie_stats (movie_id, horror_score_avg) VALUES (?, ?)";
            jdbcTemplate.update(insertSql, movieId, avg);
        } else {
            System.out.println("▶ [movie_stats] 공포 점수 평균 UPDATE 완료");
        }
    }

    public void updateSexualScoreAvg(Long movieId, double avg) {
        System.out.println("▶ [movie_stats] 선정성 점수 평균 업데이트 시도... movieId: " + movieId + ", avg: " + avg);
        String updateSql = "UPDATE movie_stats SET sexual_score_avg = ? WHERE movie_id = ?";
        int updated = jdbcTemplate.update(updateSql, avg, movieId);

        if (updated == 0) {
            System.out.println("▶ [movie_stats] 기존 데이터 없음 → 새 행 INSERT 진행");
            String insertSql = "INSERT INTO movie_stats (movie_id, sexual_score_avg) VALUES (?, ?)";
            jdbcTemplate.update(insertSql, movieId, avg);
        } else {
            System.out.println("▶ [movie_stats] 선정성 점수 평균 UPDATE 완료");
        }
    }
    
    // ✅ 공포 평균값 조회
    public Double getSavedAverageHorrorScore(Long movieId) {
        String sql = "SELECT horror_score_avg FROM movie_stats WHERE movie_id = ?";
        List<Double> result = jdbcTemplate.query(sql,
            (rs, rowNum) -> rs.getDouble("horror_score_avg"), movieId);

        return result.isEmpty() ? null : result.get(0); // ❗ 값 없으면 null 리턴
    }

    // ✅ 선정성 평균값 조회
    public Double getSavedAverageSexualScore(Long movieId) {
        String sql = "SELECT sexual_score_avg FROM movie_stats WHERE movie_id = ?";
        List<Double> result = jdbcTemplate.query(sql,
            (rs, rowNum) -> rs.getDouble("sexual_score_avg"), movieId);

        return result.isEmpty() ? null : result.get(0);
    }
  
    public void saveOrUpdateHorrorScore(String memberId, Long movieId, Integer horrorScore) {
        String sql = "INSERT INTO user_reviews (member_id, movie_id, horror_score) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE horror_score = VALUES(horror_score)";
        jdbcTemplate.update(sql, memberId, movieId, horrorScore);
    }

    public void saveOrUpdateSexualScore(String memberId, Long movieId, Integer sexualScore) {
        String sql = "INSERT INTO user_reviews (member_id, movie_id, sexual_score) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE sexual_score = VALUES(sexual_score)";
        jdbcTemplate.update(sql, memberId, movieId, sexualScore);
    }

    
    // 08.03
    
 // UserReviewRepository.java 파일에 아래 4개 메소드 추가

    // 8점 이상을 "높은 평점"의 기준으로 삼겠습니다.
    private static final int HIGH_RATING_THRESHOLD = 8;

    /**
     * [취향 분석용] 사용자의 시그니처 장르(가장 많이 보고, 평점도 높게 준)를 조회합니다.
     */
    public String findSignatureGenre(String memberId) {
        String sql = "SELECT " +
                     "    g.genre " +
                     "FROM " +
                     "    user_reviews r " +
                     "JOIN " +
                     "    movie_genres g ON r.movie_id = g.movie_id " +
                     "WHERE " +
                     "    r.member_id = ? AND r.user_rating IS NOT NULL " +
                     "GROUP BY " +
                     "    g.genre " +
                     "ORDER BY " +
                     "    COUNT(*) * AVG(r.user_rating) DESC " + // (리뷰 개수 * 평균 평점)으로 정렬
                     "LIMIT 1";
        try {
            // queryForObject는 결과가 없을 때 예외를 발생시키므로 try-catch로 감쌉니다.
            return jdbcTemplate.queryForObject(sql, String.class, memberId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null; // 결과가 없을 경우 null을 반환하여 서비스단에서 처리하도록 합니다.
        }
    }

    /**
     * [취향 분석용] 사용자가 높은 평점을 준 영화에 가장 많이 등장한 인물(배우/감독)을 조회합니다.
     */
    public Map<String, String> findFavoritePerson(String memberId) {
        String sql = "SELECT " +
                     "    a.name AS personName, " +
                     "    ma.role_type AS personRole " +
                     "FROM " +
                     "    user_reviews r " +
                     "JOIN " +
                     "    movie_actors ma ON r.movie_id = ma.movie_id " +
                     "JOIN " +
                     "    actors a ON ma.actor_id = a.id " +
                     "WHERE " +
                     "    r.member_id = ? AND r.user_rating >= ? " + // 높은 평점을 준 영화만 대상
                     "GROUP BY " +
                     "    a.id, a.name, ma.role_type " +
                     "ORDER BY " +
                     "    COUNT(*) DESC, a.name ASC " + // 가장 많이 등장한 순서대로
                     "LIMIT 1";
        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Map<String, String> person = new HashMap<>();
                person.put("name", rs.getString("personName"));
                person.put("role", rs.getString("personRole"));
                return person;
            }, memberId, HIGH_RATING_THRESHOLD);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * [취향 분석용] 사용자가 가장 활발하게 리뷰를 작성한 요일을 조회합니다.
     */
    public String findActivityPattern(String memberId) {
        String sql = "SELECT " +
                     "    CASE DAYOFWEEK(created_at) " +
                     "        WHEN 1 THEN '일요일' WHEN 2 THEN '월요일' WHEN 3 THEN '화요일' " +
                     "        WHEN 4 THEN '수요일' WHEN 5 THEN '목요일' WHEN 6 THEN '금요일' " +
                     "        WHEN 7 THEN '토요일' " +
                     "    END as day_of_week " +
                     "FROM " +
                     "    user_reviews " +
                     "WHERE " +
                     "    member_id = ? " +
                     "GROUP BY " +
                     "    day_of_week " +
                     "ORDER BY " +
                     "    COUNT(*) DESC " +
                     "LIMIT 1";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, memberId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * [취향 분석용] 사용자가 높은 평점을 준 영화들의 평균 개봉연도와 평균 상영시간을 조회합니다.
     */
    public Map<String, Double> findMoviePreferenceMeta(String memberId) {
        // REGEXP_REPLACE를 지원하는 DB(MySQL 8.0+, MariaDB 10.0.5+)에서만 동작합니다.
        String sql = "SELECT " +
                     "    AVG(m.year) as avg_year, " +
                     "    AVG(CAST(REGEXP_REPLACE(m.runtime, '[^0-9]+', '') AS UNSIGNED)) as avg_runtime " +
                     "FROM " +
                     "    user_reviews r " +
                     "JOIN " +
                     "    movies m ON r.movie_id = m.id " +
                     "WHERE " +
                     "    r.member_id = ? AND r.user_rating >= ?";
        
        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Map<String, Double> meta = new HashMap<>();
                // 결과가 NULL일 수 있으므로 getDouble 대신 getObject로 받고 확인
                Object avgYearObj = rs.getObject("avg_year");
                Object avgRuntimeObj = rs.getObject("avg_runtime");

                if (avgYearObj != null) {
                    meta.put("avgYear", ((Number) avgYearObj).doubleValue());
                }
                if (avgRuntimeObj != null) {
                    meta.put("avgRuntime", ((Number) avgRuntimeObj).doubleValue());
                }
                return meta;
            }, memberId, HIGH_RATING_THRESHOLD);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
             return null;
        }
    }


}
