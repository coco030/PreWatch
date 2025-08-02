package com.springmvc.repository;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.movie;
import com.springmvc.service.StatService;

@Repository
public class movieRepository {
	
	@Autowired
	private StatService statService;

	private final JdbcTemplate jdbcTemplate;

    private static final Logger logger = LoggerFactory.getLogger(movieRepository.class);

    @Autowired
    public movieRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        logger.info("movieRepository 초기화: JdbcTemplate 주입 완료.");
    }

    public List<movie> findAll() {
        logger.debug("movieRepository.findAll() 호출: DB에서 모든 영화 조회 시도.");
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at FROM movies ORDER BY like_count DESC, created_at DESC";

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));

        logger.info("DB에서 {}개의 영화 레코드 성공적으로 가져옴.", list.size());
        return list;
    }

    public movie findById(Long id) {
        logger.debug("movieRepository.findById({}) 호출: DB에서 특정 영화 조회 시도.", id);
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at FROM movies WHERE id = ?";
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

    public movie findByApiId(String apiId) {
        logger.debug("movieRepository.findByApiId({}) 호출: DB에서 API ID로 영화 조회 시도.", apiId);
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

    public List<movie> findAllUpcomingMovies() {
        logger.debug("movieRepository.findAllUpcomingMovies() 호출: 모든 개봉 예정작 조회 시도.");
        String sql = """
            SELECT
                id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at, like_count, runtime, rated,
                DATEDIFF(release_date, CURDATE()) AS dday
            FROM movies
            WHERE release_date > CURDATE()
            ORDER BY release_date ASC
            """;
        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
        logger.info("DB에서 모든 개봉 예정작 레코드 {}개 성공적으로 가져옴.", list.size());
        return list;
    }
    
    public Long save(movie movie) {
        logger.debug("movieRepository.save() 호출: 영화 '{}' 저장 시도.", movie.getTitle());

        String sql = "INSERT INTO movies (api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();
        int rowsAffected = jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id"});
            ps.setString(1, movie.getApiId());
            ps.setString(2, movie.getTitle());
            ps.setString(3, movie.getDirector());
            ps.setInt(4, movie.getYear());
            ps.setDate(5, movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null);
            ps.setString(6, movie.getGenre());
            ps.setDouble(7, movie.getRating());
            ps.setDouble(8, movie.getViolence_score_avg());
            ps.setString(9, movie.getOverview());
            ps.setString(10, movie.getPosterPath());
            ps.setInt(11, movie.getLikeCount());
            ps.setString(12, movie.getRuntime());
            ps.setString(13, movie.getRated());
            return ps;
        }, keyHolder);

        if (rowsAffected > 0) {
            Long movieId = Objects.requireNonNull(keyHolder.getKey()).longValue();
            movie.setId(movieId);
            logger.info("DB에 영화 '{}' 저장 완료. ID = {}", movie.getTitle(), movieId);

            String selectIdSql = "SELECT id FROM movies WHERE api_id = ?";
            Long movieIdByApi = jdbcTemplate.queryForObject(selectIdSql, Long.class, movie.getApiId());
            System.out.println("DEBUG:: SELECT로 찾은 movie id = " + movieIdByApi + ", movie.getId() = " + movie.getId());

            return movieId;
        } else {
            logger.error("영화 '{}' 저장 실패: 데이터베이스에 삽입되지 않았습니다.", movie.getTitle());
            throw new RuntimeException("영화 저장 실패: 데이터베이스에 삽입되지 않았습니다.");
        }
    }

    public void update(movie movie) {
        logger.debug("movieRepository.update() 호출: 영화 ID {} 업데이트 시도.", movie.getId());
        String sql = "UPDATE movies SET api_id=?, title=?, director=?, year=?, release_date=?, genre=?, rating=?, violence_score_avg=?, overview=?, poster_path=?, like_count=?, runtime=?, rated=? WHERE id=?";
        int rowsAffected = jdbcTemplate.update(sql,
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
            movie.getRuntime(),
            movie.getRated(),
            movie.getId());

        if (rowsAffected > 0) {
            logger.info("DB에서 영화 ID {} 업데이트 완료.", movie.getId());
        } else {
            logger.warn("DB에서 영화 ID {}를 찾을 수 없어 업데이트되지 않음.", movie.getId());
        }
    }

    public void delete(Long id) {
        logger.debug("movieRepository.delete({}) 호출: DB에서 영화 삭제 시도.", id);
        String sql = "DELETE FROM movies WHERE id = ?";
        int deletedRows = jdbcTemplate.update(sql, id);
        if (deletedRows > 0) {
            logger.info("DB에서 영화 ID {} 레코드 성공적으로 삭제됨.", id);
        } else {
            logger.warn("DB에서 영화 ID {}를 찾을 수 없어 삭제되지 않음.", id);
        }
    }
    
    // 마이페이지 전용 메서드 (영화 ID로 제목과 포스터 경로만 조회)
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
            logger.warn("DB에서 영화 ID {}에 해당하는 제목/포스터를 찾을 수 없습니다.", id);
            return null;
        } catch (Exception e) {
            logger.error("DB 영화 ID {} 조회 중 오류 발생: {}", id, e.getMessage(), e);
            throw new RuntimeException("영화 조회 실패", e);
        }
    }

    public void updateAverageScores(Long movieId, double avgRating, double avgViolence) {
        String sql = "UPDATE movies SET rating = ?, violence_score_avg = ? WHERE id = ?";
        int rowsAffected = jdbcTemplate.update(sql, avgRating, avgViolence, movieId);
        if (rowsAffected > 0) {
            logger.info("영화 ID {}의 평점 및 잔혹도 평균 업데이트 완료.", movieId);
        } else {
            logger.warn("영화 ID {}의 평점 및 잔혹도 평균 업데이트 실패: 영화를 찾을 수 없음.", movieId);
        }
    }

    public void incrementLikeCount(Long movieId) {
        logger.debug("영화 ID {}의 찜 개수 1 증가 시도.", movieId);
        String sql = "UPDATE movies SET like_count = like_count + 1 WHERE id = ?";
        int rowsAffected = jdbcTemplate.update(sql, movieId);
        if (rowsAffected > 0) {
            logger.info("영화 ID {}의 찜 개수 1 증가 완료.", movieId);
        } else {
            logger.warn("영화 ID {}의 찜 개수 1 증가 실패: 영화를 찾을 수 없음.", movieId);
        }
    }

    public void decrementLikeCount(Long movieId) {
        logger.debug("영화 ID {}의 찜 개수 1 감소 시도.", movieId);
        String sql = "UPDATE movies SET like_count = GREATEST(0, like_count - 1) WHERE id = ?";
        int rowsAffected = jdbcTemplate.update(sql, movieId);
        if (rowsAffected > 0) {
            logger.info("영화 ID {}의 찜 개수 1 감소 완료.", movieId);
        } else {
            logger.warn("영화 ID {}의 찜 개수 1 감소 실패: 영화를 찾을 수 없음.", movieId);
        }
    }

    public List<movie> findTop6RecommendedMoviesByLikeCount() {
        logger.debug("movieRepository.findTop6RecommendedMoviesByLikeCount() 호출: 찜 개수 기준 상위 6개 영화 조회 시도.");
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at " +
                     "FROM movies " +
                     "ORDER BY like_count DESC, created_at DESC " +
                     "LIMIT 6";

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
        logger.info("DB에서 찜 개수 기준 상위 {}개 영화 레코드 성공적으로 가져옴.", list.size());
        return list;
    }

    public List<movie> findRecentMovies(int limit) {
        logger.debug("movieRepository.findRecentMovies({}) 호출: 최근 등록된 영화 조회 시도.", limit);
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at " +
                     "FROM movies " +
                     "ORDER BY created_at DESC " +
                     "LIMIT ?";

        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class), limit);
        logger.info("DB에서 최근 등록된 영화 레코드 {}개 성공적으로 가져옴.", list.size());
        return list;
    }

    public List<movie> findAllRecentMovies() {
        logger.debug("JdbcMovieRepository.findAllRecentMovies() 호출: 모든 최근 등록된 영화 조회 시도.");
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at " +
                     "FROM movies " +
                     "ORDER BY created_at DESC";
        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
        logger.info("DB에서 모든 최근 등록된 영화 레코드 {}개 성공적으로 가져옴.", list.size());
        return list;
    }

    public List<movie> findAllRecommendedMovies() {
        logger.debug("movieRepository.findAllRecommendedMovies() 호출: 모든 추천 랭킹 영화 조회 시도.");
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at " +
                     "FROM movies " +
                     "ORDER BY like_count DESC, created_at DESC";
        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
        logger.info("DB에서 모든 추천 랭킹 영화 레코드 {}개 성공적으로 가져옴.", list.size());
        return list;
    }

    public List<movie> getUpcomingMoviesWithDday() {
        String sql = """
            SELECT
                id,
                api_id,
                title,
                director,
                year,
                release_date,
                genre,
                rating,
                violence_score_avg,
                overview,
                poster_path,
                created_at,
                updated_at,
                like_count,
                runtime,
                rated,
                DATEDIFF(release_date, CURDATE()) AS dday
            FROM movies
            WHERE DATEDIFF(release_date, CURDATE()) >= -7
            ORDER BY ABS(DATEDIFF(release_date, CURDATE())) ASC
            LIMIT 5
            """;

        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
    }

    public void insertGenreMapping(Long movieId, String genre) {
        String sql = "INSERT INTO movie_genres (movie_id, genre) VALUES (?, ?)";
        try {
            jdbcTemplate.update(sql, movieId, genre);
            logger.info("영화 ID {}에 장르 '{}' 매핑 성공.", movieId, genre);
        } catch (Exception e) {
            logger.error("영화 ID {}에 장르 '{}' 매핑 중 오류 발생: {}", movieId, genre, e.getMessage(), e);
        }
    }

    public List<movie> findByReleaseDateBetween(LocalDate startDate, LocalDate endDate) { // 07-31: 추가된 메서드
        logger.debug("movieRepository.findByReleaseDateBetween({}, {}) 호출: 특정 기간 내 영화 조회 시도.", startDate, endDate); // 07-31: 추가된 메서드
        String sql = """
            SELECT
                id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, like_count, runtime, rated, created_at, updated_at
            FROM movies
            WHERE release_date BETWEEN ? AND ?
            ORDER BY release_date ASC
            """; // 07-31: 추가된 메서드
        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class), // 07-31: 추가된 메서드
                                          Date.valueOf(startDate), Date.valueOf(endDate)); // 07-31: 추가된 메서드
        logger.info("DB에서 {} ~ {} 기간 내 영화 레코드 {}개 성공적으로 가져옴.", startDate, endDate, list.size()); // 07-31: 추가된 메서드
        return list; // 07-31: 추가된 메서드
    }
}