package com.springmvc.repository;

import com.springmvc.domain.AdminBannerMovie; // (7-24 오후12:41 추가 된 코드)
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.EmptyResultDataAccessException;


@Repository // (7-24 오후12:41 추가 된 코드)
public class AdminBannerMovieRepository { // (7-24 오후12:41 추가 된 코드)

    private static final Logger logger = LoggerFactory.getLogger(AdminBannerMovieRepository.class); // (7-24 오후12:41 추가 된 코드)

    @Autowired // (7-24 오후12:41 추가 된 코드)
    private JdbcTemplate jdbcTemplate; // (7-24 오후12:41 추가 된 코드)

    // 배너에 등록된 모든 영화 ID를 순서대로 조회 (7-24 오후12:41 추가 된 코드)
    public List<AdminBannerMovie> findAllOrdered() { // (7-24 오후12:41 추가 된 코드)
        logger.debug("AdminBannerMovieRepository.findAllOrdered() 호출: 배너 영화 조회 시도."); // (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, movie_id, display_order, created_at FROM admin_banner_movies ORDER BY display_order ASC, created_at DESC"; // (7-24 오후12:41 추가 된 코드)
        List<AdminBannerMovie> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(AdminBannerMovie.class)); // (7-24 오후12:41 추가 된 코드)
        logger.info("DB에서 배너 영화 레코드 {}개 성공적으로 가져옴.", list.size()); // (7-24 오후12:41 추가 된 코드)
        return list; // (7-24 오후12:41 추가 된 코드)
    }

    // 특정 movie_id가 이미 배너에 등록되어 있는지 확인 (7-24 오후12:41 추가 된 코드)
    public AdminBannerMovie findByMovieId(Long movieId) { // (7-24 오후12:41 추가 된 코드)
        logger.debug("AdminBannerMovieRepository.findByMovieId({}) 호출: 배너 영화 존재 여부 확인 시도.", movieId); // (7-24 오후12:41 추가 된 코드)
        String sql = "SELECT id, movie_id, display_order, created_at FROM admin_banner_movies WHERE movie_id = ?"; // (7-24 오후12:41 추가 된 코드)
        try {
            AdminBannerMovie bannerMovie = jdbcTemplate.queryForObject(sql, new BeanPropertyRowMapper<>(AdminBannerMovie.class), movieId); // (7-24 오후12:41 추가 된 코드)
            logger.info("DB에서 movie_id {}에 해당하는 배너 영화 찾음.", movieId); // (7-24 오후12:41 추가 된 코드)
            return bannerMovie; // (7-24 오후12:41 추가 된 코드)
        } catch (EmptyResultDataAccessException e) {
            logger.warn("DB에서 movie_id {}에 해당하는 배너 영화를 찾을 수 없음.", movieId); // (7-24 오후12:41 추가 된 코드)
            return null; // (7-24 오후12:41 추가 된 코드)
        }
    }

    // 배너에 영화 추가 (7-24 오후12:41 추가 된 코드)
    public void addMovie(Long movieId) { // (7-24 오후12:41 추가 된 코드)
        logger.debug("AdminBannerMovieRepository.addMovie({}) 호출: 배너에 영화 추가 시도.", movieId); // (7-24 오후12:41 추가 된 코드)
        String sql = "INSERT INTO admin_banner_movies (movie_id) VALUES (?)"; // display_order는 DEFAULT 0 (7-24 오후12:41 추가 된 코드)
        jdbcTemplate.update(sql, movieId); // (7-24 오후12:41 추가 된 코드)
        logger.info("배너에 영화 ID {} 추가 완료.", movieId); // (7-24 오후12:41 추가 된 코드)
    }

    // 배너에서 영화 삭제 (7-24 오후12:41 추가 된 코드)
    public void removeMovie(Long movieId) { // (7-24 오후12:41 추가 된 코드)
        logger.debug("AdminBannerMovieRepository.removeMovie({}) 호출: 배너에서 영화 삭제 시도.", movieId); // (7-24 오후12:41 추가 된 코드)
        String sql = "DELETE FROM admin_banner_movies WHERE movie_id = ?"; // (7-24 오후12:41 추가 된 코드)
        jdbcTemplate.update(sql, movieId); // (7-24 오후12:41 추가 된 코드)
        logger.info("배너에서 영화 ID {} 삭제 완료.", movieId); // (7-24 오후12:41 추가 된 코드)
    }
}
