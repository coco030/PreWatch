package com.springmvc.repository;

import java.sql.Date;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.movie;

@Repository
public class movieRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final Logger logger = LoggerFactory.getLogger(movieRepository.class);

    public movieRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        logger.info("movieRepository 초기화: JdbcTemplate 주입 완료.");
    }

    // findAll 메서드: 데이터베이스 'movies' 테이블의 모든 영화 정보를 조회합니다.
    // 목적: 영화 목록을 보여줄 때 사용되며, 찜 개수(like_count)를 기준으로 내림차순 정렬됩니다.
    public List<movie> findAll() {
        logger.debug("movieRepository.findAll() 호출: DB에서 모든 영화 조회 시도.");
        // is_recommended 컬럼 조회에서 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count FROM movies ORDER BY like_count DESC, created_at DESC";

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));

        logger.info("DB에서 {}개의 영화 레코드 성공적으로 가져옴.", list.size());
        return list;
    }

    // findById 메서드: 주어진 ID에 해당하는 영화 정보를 데이터베이스에서 조회합니다.
    // 목적: 특정 영화의 상세 정보를 보여주거나, 수정/삭제 전에 기존 정보를 가져올 때 사용됩니다.
    public movie findById(Long id) {
        logger.debug("movieRepository.findById({}) 호출: DB에서 특정 영화 조회 시도.", id);
        // is_recommended 컬럼 조회에서 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count FROM movies WHERE id = ?";
        try {
            movie movie = jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(movie.class), id);
            logger.info("DB에서 영화 ID {} 레코드 성공적으로 가져옴.", id);
            return movie;
        } catch (EmptyResultDataAccessException e) {
            logger.warn("DB에서 영화 ID {}를 찾을 수 없습니다.", id);
            return null;
        } catch (Exception e) {
            logger.error("DB 영화 ID {} 조회 중 오류 발생: {}", id, e.getMessage(), e);
            throw new RuntimeException("영화 조회 실패", e);
        }
    }

    // findByApiId 메서드: 외부 API ID (imdbID)를 사용하여 데이터베이스에서 영화를 조회합니다.
    // 목적: API 검색 결과에 로컬 평점/잔혹도를 덮어쓸 때 사용됩니다.
    public movie findByApiId(String apiId) {
        logger.debug("movieRepository.findByApiId({}) 호출: DB에서 API ID로 영화 조회 시도.", apiId);
        // is_recommended 컬럼 조회에서 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count FROM movies WHERE api_id = ?";
        try {
            movie movie = jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(movie.class), apiId);
            logger.info("DB에서 API ID '{}'에 해당하는 영화 레코드 성공적으로 가져옴.", apiId);
            return movie;
        } catch (EmptyResultDataAccessException e) {
            logger.warn("DB에서 API ID '{}'에 해당하는 영화를 찾을 수 없습니다.", apiId);
            return null;
        } catch (Exception e) {
            logger.error("DB 영화 API ID '{}' 조회 중 오류 발생: {}", apiId, e.getMessage(), e);
            throw new RuntimeException("영화 조회 실패", e);
        }
    }

    // save 메서드: 새로운 movie 객체를 데이터베이스 'movies' 테이블에 삽입합니다.
    // 목적: 관리자가 새 영화를 직접 등록하거나, API에서 가져온 영화를 등록할 때 사용됩니다.
    public void save(movie movie) {
        logger.debug("movieRepository.save() 호출: 영화 '{}' 저장 시도.", movie.getTitle());
        // is_recommended 컬럼 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "INSERT INTO movies (api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"; // like_count 포함 총 11개 파라미터

        jdbcTemplate.update(sql,
            movie.getApiId(),
            movie.getTitle(),
            movie.getDirector(),
            movie.getYear(),
            movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null,
            movie.getGenre(),
            movie.getRating(),
            movie.getViolence_score_avg(),
            movie.getOverview(),
            movie.getPosterPath(),
            movie.getLikeCount());

        logger.info("DB에 영화 '{}' 저장 완료.", movie.getTitle());
    }

    // update 메서드: 기존 movie 객체의 정보를 데이터베이스 'movies' 테이블에서 업데이트합니다.
    // 목적: 관리자가 영화 정보를 수정할 때 사용됩니다.
    public void update(movie movie) {
        logger.debug("movieRepository.update() 호출: 영화 ID {} 업데이트 시도.", movie.getId());
        // is_recommended 컬럼 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "UPDATE movies SET api_id=?, title=?, director=?, year=?, release_date=?, genre=?, rating=?, violence_score_avg=?, overview=?, poster_path=?, like_count=? WHERE id=?"; // like_count 포함
        jdbcTemplate.update(sql,
            movie.getApiId(),
            movie.getTitle(),
            movie.getDirector(),
            movie.getYear(),
            movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null,
            movie.getGenre(),
            movie.getRating(),
            movie.getViolence_score_avg(),
            movie.getOverview(),
            movie.getPosterPath(),
            movie.getLikeCount(),
            movie.getId());

        logger.info("DB에서 영화 ID {} 업데이트 완료.", movie.getId());
    }

    // delete 메서드: 주어진 ID에 해당하는 영화 정보를 데이터베이스 'movies' 테이블에서 삭제합니다.
    public void delete(Long id) {
        logger.debug("movieRepository.delete({}) 호출: DB에서 영화 삭제 시도.", id);
        String sql = "DELETE FROM movies WHERE id=?";
        jdbcTemplate.update(sql, id);
        logger.info("DB에서 영화 ID {} 삭제 완료.", id);
    }

    // updateAverageScores 메서드: 특정 영화의 평균 평점과 잔혹도 점수를 업데이트합니다.
    public void updateAverageScores(Long movieId, double avgRating, double avgViolence) {
        String sql = "UPDATE movies SET rating = ?, violence_score_avg = ? WHERE id = ?";
        jdbcTemplate.update(sql, avgRating, avgViolence, movieId);
        logger.info("영화 ID {}의 평점 및 잔혹도 평균 업데이트 완료.", movieId);
    }

    //마이페이지 전용 메서드
    public movie findTitleAndPosterById(Long id) {
        String sql = "SELECT id, title, poster_path FROM movies WHERE id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                movie m = new movie();
                m.setId(rs.getLong("id"));
                m.setTitle(rs.getString("title"));
                m.setPosterPath(rs.getString("poster_path"));
                return m;
            }, id);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    // ⭐ 추가: 찜 개수 업데이트 메서드 ⭐
    // 목적: 사용자가 찜을 추가/취소할 때 해당 영화의 like_count를 증감합니다.
    public void incrementLikeCount(Long movieId) {
        logger.debug("영화 ID {}의 찜 개수 1 증가 시도.", movieId);
        String sql = "UPDATE movies SET like_count = like_count + 1 WHERE id = ?";
        jdbcTemplate.update(sql, movieId);
        logger.info("영화 ID {}의 찜 개수 1 증가 완료.", movieId);
    }

    public void decrementLikeCount(Long movieId) {
        logger.debug("영화 ID {}의 찜 개수 1 감소 시도.", movieId);
        String sql = "UPDATE movies SET like_count = GREATEST(0, like_count - 1) WHERE id = ?"; // 0 미만으로 내려가지 않게 방지
        jdbcTemplate.update(sql, movieId);
        logger.info("영화 ID {}의 찜 개수 1 감소 완료.", movieId);
    }

    // --- ⭐ 기존 메서드: 추천 랭킹 (like_count 기준) 영화 조회 ⭐ (7-24 오후12:41 추가 된 코드)
    /**
     * 찜 개수(like_count)를 기준으로 내림차순 정렬하여 상위 5개의 영화 목록을 조회합니다. (7-24 오후12:41 추가 된 코드)
     * 찜 개수가 같을 경우, created_at 최신순으로 정렬됩니다. (7-24 오후12:41 추가 된 코드)
     * @return 찜 개수 기준 상위 5개 영화 목록 (7-24 오후12:41 추가 된 코드)
     */
    public List<movie> findTop5RecommendedMoviesByLikeCount() { // (7-24 오후12:41 추가 된 코드)
        logger.debug("movieRepository.findTop5RecommendedMoviesByLikeCount() 호출: 찜 개수 기준 상위 5개 영화 조회 시도."); // (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count " + // (7-24 오후12:41 추가 된 코드)
                     "FROM movies " + // (7-24 오후12:41 추가 된 코드)
                     "ORDER BY like_count DESC, created_at DESC " + // 찜 개수 내림차순, 동점 시 생성일 최신순 (7-24 오후12:41 추가 된 코드)
                     "LIMIT 5"; // 상위 5개만 가져오기 (7-24 오후12:41 추가 된 코드)

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class)); // (7-24 오후12:41 추가 된 코드)
        logger.info("DB에서 찜 개수 기준 상위 5개 영화 레코드 {}개 성공적으로 가져옴.", list.size()); // (7-24 오후12:41 추가 된 코드)
        return list; // (7-24 오후12:41 추가 된 코드)
    } // (7-24 오후12:41 추가 된 코드)

    // --- 추가: 최근 등록된 영화 조회 메서드 (main.jsp의 "최근 등록된 영화" 섹션을 위함) ---
    /**
     * 최근 등록된 영화를 개봉일 기준으로 내림차순 정렬하여 지정된 개수만큼 조회합니다.
     * @param limit 가져올 영화의 개수
     * @return 최근 등록된 영화 목록
     */
    public List<movie> findRecentMovies(int limit) {
        logger.debug("movieRepository.findRecentMovies({}) 호출: 최근 등록된 영화 조회 시도.", limit);
        // is_recommended 컬럼 조회에서 제거 (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count " +
                     "FROM movies " +
                     "ORDER BY created_at DESC " +
                     "LIMIT ?";

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class), limit);
        logger.info("DB에서 최근 등록된 영화 레코드 {}개 성공적으로 가져옴.", list.size());
        return list;
    }
    
    // ============ coco030이 추가한 내역 25.07.24 오후 ====
    // 최근 개봉 예정작

	public List<Map<String, Object>> getUpcomingMoviesWithDday() {
	    String sql = """
	        SELECT 
	            id,
	            title,
	            release_date,
	            poster_path,
	            DATEDIFF(release_date, CURDATE()) AS dday
	        FROM movies
	        ORDER BY release_date ASC
	        LIMIT 5
	    """;
	
	    return jdbcTemplate.queryForList(sql);
	}
	
// ===========coco030이 추가한 내역  끝 ==== ///
	
	
    
}