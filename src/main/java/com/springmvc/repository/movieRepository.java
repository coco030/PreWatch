package com.springmvc.repository;

import java.sql.Date;            
import java.sql.SQLException;      
import java.time.LocalDate;        
import java.util.List;             

import org.slf4j.Logger;         
import org.slf4j.LoggerFactory; 
import org.springframework.beans.factory.annotation.Autowired;       
import org.springframework.dao.EmptyResultDataAccessException;       
import org.springframework.jdbc.core.BeanPropertyRowMapper;          
import org.springframework.jdbc.core.JdbcTemplate;                   
import org.springframework.stereotype.Repository;                    

import com.springmvc.domain.movie; 

// movieRepository 클래스: 영화 데이터 접근(CRUD) 메서드 구현.
// 목적: JdbcTemplate을 사용하여 'movies' 테이블과 상호작용.
@Repository // Spring 빈으로 등록
public class movieRepository {

	@Autowired // JdbcTemplate 빈 자동 주입
	private JdbcTemplate jdbcTemplate;

	private static final Logger logger = LoggerFactory.getLogger(movieRepository.class); // Logger 객체 초기화

    // 생성자를 통한 JdbcTemplate 주입
    public movieRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        logger.info("movieRepository 초기화: JdbcTemplate 주입 완료.");
    }

    // findAll 메서드: 'movies' 테이블의 모든 영화 정보 조회.
    // 목적: 영화 목록 표시.
    public List<movie> findAll() {
        logger.debug("movieRepository.findAll() 호출: DB에서 모든 영화 조회 시도.");
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at FROM movies";
        // JdbcTemplate.query(): 여러 행 결과를 movie 객체 리스트로 매핑 (BeanPropertyRowMapper 사용)
        List<movie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(movie.class));
        logger.info("DB에서 {}개의 영화 레코드 성공적으로 가져옴.", list.size());
        return list;
    }

    // findById 메서드: 주어진 ID에 해당하는 영화 정보 조회.
    // 목적: 특정 영화 상세 정보 표시, 수정/삭제 전 정보 가져오기.
    public movie findById(Long id) {
        logger.debug("movieRepository.findById({}) 호출: DB에서 특정 영화 조회 시도.", id);
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at FROM movies WHERE id = ?";
        try {
            // JdbcTemplate.queryForObject(): 단일 행 결과를 movie 객체로 매핑 (BeanPropertyRowMapper 사용)
            movie movie = jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(movie.class), id);
            logger.info("DB에서 영화 ID {} 레코드 성공적으로 가져옴.", id);
            return movie;
        } catch (EmptyResultDataAccessException e) {
            logger.warn("DB에서 영화 ID {}를 찾을 수 없습니다.", id);
            return null; // 영화 없으면 null 반환
        } catch (Exception e) {
            logger.error("DB 영화 ID {} 조회 중 오류 발생: {}", id, e.getMessage(), e);
            throw new RuntimeException("영화 조회 실패", e); // 런타임 예외로 감싸서 던짐
        }
    }

    // findByApiId 메서드: 외부 API ID (imdbID)를 사용하여 영화 조회.
    // 목적: API 검색 결과에 로컬 평점/폭력성지수 덮어쓰기 위해 사용.
    public movie findByApiId(String apiId) {
        logger.debug("movieRepository.findByApiId({}) 호출: DB에서 API ID로 영화 조회 시도.", apiId);
        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at FROM movies WHERE api_id = ?";
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

    // save 메서드: 새 movie 객체를 'movies' 테이블에 삽입.
    // 목적: 새 영화 직접 등록 또는 API 영화 등록.
    public void save(movie movie) {
        logger.debug("movieRepository.save() 호출: 영화 '{}' 저장 시도.", movie.getTitle());
        String sql = "INSERT INTO movies (api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        // JdbcTemplate.update(): INSERT 쿼리 실행 (LocalDate를 sql.Date로 변환)
        jdbcTemplate.update(sql,
            movie.getApiId(),
            movie.getTitle(),
            movie.getDirector(),
            movie.getYear(),
            movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null,
            movie.getGenre(),
            movie.getRating(),
            movie.getviolence_score_avg(),
            movie.getOverview(),
            movie.getPosterPath());
        logger.info("DB에 영화 '{}' 저장 완료.", movie.getTitle());
    }

    // update 메서드: 기존 movie 객체 정보를 'movies' 테이블에서 업데이트.
    // 목적: 관리자가 영화 정보 수정.
    public void update(movie movie) {
        logger.debug("movieRepository.update() 호출: 영화 ID {} 업데이트 시도.", movie.getId());
        String sql = "UPDATE movies SET api_id=?, title=?, director=?, year=?, release_date=?, genre=?, rating=?, violence_score_avg=?, overview=?, poster_path=? WHERE id=?";
        // JdbcTemplate.update(): UPDATE 쿼리 실행 (LocalDate를 sql.Date로 변환)
        jdbcTemplate.update(sql,
            movie.getApiId(),
            movie.getTitle(),
            movie.getDirector(),
            movie.getYear(),
            movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null,
            movie.getGenre(),
            movie.getRating(),
            movie.getviolence_score_avg(),
            movie.getOverview(),
            movie.getPosterPath(),
            movie.getId());
        logger.info("DB에서 영화 ID {} 업데이트 완료.", movie.getId());
    }

    // delete 메서드: 주어진 ID에 해당하는 영화 정보 삭제.
    // 목적: 관리자가 영화 삭제. (관련 포스터 파일도 삭제될 수 있음)
    public void delete(Long id) {
        logger.debug("movieRepository.delete({}) 호출: DB에서 영화 삭제 시도.", id);
        String sql = "DELETE FROM movies WHERE id=?";
        // JdbcTemplate.update(): DELETE 쿼리 실행
        jdbcTemplate.update(sql, id);
        logger.info("DB에서 영화 ID {} 삭제 완료.", id);
    }

    // updateAverageScores 메서드: 특정 영화의 평균 평점과 폭력성 점수 업데이트.
    // 목적: 사용자 리뷰가 변경될 때 해당 영화의 평균 값 반영.
    public void updateAverageScores(Long movieId, double avgRating, double avgViolence) {
        String sql = "UPDATE movies SET rating = ?, violence_score_avg = ? WHERE id = ?";
        jdbcTemplate.update(sql, avgRating, avgViolence, movieId);
        logger.info("영화 ID {}의 평점 및 폭력성지수 평균 업데이트 완료.", movieId);
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
}