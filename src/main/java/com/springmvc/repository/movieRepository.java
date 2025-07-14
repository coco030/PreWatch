package com.springmvc.repository;

import com.springmvc.domain.movie;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Repository
public class movieRepository {

    private static final Logger logger = LoggerFactory.getLogger(movieRepository.class);

    private final DataSource dataSource;

    @Autowired
    public movieRepository(DataSource dataSource) {
        this.dataSource = dataSource;
        logger.info("movieRepository 초기화: DataSource 주입 완료.");
    }

    public List<movie> findAll() {
        logger.debug("movieRepository.findAll() 호출: DB에서 모든 영화 조회 시도.");
        List<movie> list = new ArrayList<>();

        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at FROM movies";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            logger.debug("SQL 실행: {}", sql);
            while (rs.next()) {
                movie movie = new movie();
                movie.setId(rs.getLong("id"));
                movie.setApiId(rs.getString("api_id"));
                movie.setTitle(rs.getString("title"));
                movie.setDirector(rs.getString("director"));
                movie.setYear(rs.getInt("year"));
                Date sqlDate = rs.getDate("release_date");
                movie.setReleaseDate(sqlDate != null ? sqlDate.toLocalDate() : null);
                movie.setGenre(rs.getString("genre"));
                movie.setRating(rs.getDouble("rating")); // rating 조회
                movie.setviolence_score_avg(rs.getDouble("violence_score_avg")); // violence_score_avg 조회
                movie.setOverview(rs.getString("overview"));
                movie.setPosterPath(rs.getString("poster_path"));
                Timestamp createdAtTimestamp = rs.getTimestamp("created_at");
                if (createdAtTimestamp != null) {
                    movie.setCreatedAt(createdAtTimestamp.toLocalDateTime());
                }
                Timestamp updatedAtTimestamp = rs.getTimestamp("updated_at");
                if (updatedAtTimestamp != null) {
                    movie.setUpdatedAt(updatedAtTimestamp.toLocalDateTime());
                }
                list.add(movie);
            }
            logger.info("DB에서 {}개의 영화 레코드 성공적으로 가져옴.", list.size());

        } catch (SQLException e) {
            logger.error("DB 영화 목록 조회 중 오류 발생: {}", e.getMessage(), e);
            throw new RuntimeException("영화 목록 조회 실패", e);
        }

        return list;
    }

    public movie findById(Long id) {
        logger.debug("movieRepository.findById({}) 호출: DB에서 특정 영화 조회 시도.", id);

        String sql = "SELECT id, api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path, created_at, updated_at FROM movies WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            logger.debug("SQL 실행: {}", sql);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                movie movie = new movie();
                movie.setId(rs.getLong("id"));
                movie.setApiId(rs.getString("api_id"));
                movie.setTitle(rs.getString("title"));
                movie.setDirector(rs.getString("director"));
                movie.setYear(rs.getInt("year"));
                Date sqlDate = rs.getDate("release_date");
                movie.setReleaseDate(sqlDate != null ? sqlDate.toLocalDate() : null);
                movie.setGenre(rs.getString("genre"));
                movie.setRating(rs.getDouble("rating")); // rating 조회
                movie.setviolence_score_avg(rs.getDouble("violence_score_avg")); // violence_score_avg 조회
                movie.setOverview(rs.getString("overview"));
                movie.setPosterPath(rs.getString("poster_path"));
                Timestamp createdAtTimestamp = rs.getTimestamp("created_at");
                if (createdAtTimestamp != null) {
                    movie.setCreatedAt(createdAtTimestamp.toLocalDateTime());
                }
                Timestamp updatedAtTimestamp = rs.getTimestamp("updated_at");
                if (updatedAtTimestamp != null) {
                    movie.setUpdatedAt(updatedAtTimestamp.toLocalDateTime());
                }
                logger.info("DB에서 영화 ID {} 레코드 성공적으로 가져옴.", id);
                return movie;
            } else {
                logger.warn("DB에서 영화 ID {}를 찾을 수 없습니다.", id);
            }

        } catch (SQLException e) {
            logger.error("DB 영화 ID {} 조회 중 오류 발생: {}", id, e.getMessage(), e);
            throw new RuntimeException("영화 조회 실패", e);
        }
        return null;
    }

    public void save(movie movie) {
        logger.debug("movieRepository.save() 호출: 영화 '{}' 저장 시도.", movie.getTitle());
        String sql = "INSERT INTO movies (api_id, title, director, year, release_date, genre, rating, violence_score_avg, overview, poster_path) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, movie.getApiId());
            ps.setString(2, movie.getTitle());
            ps.setString(3, movie.getDirector());
            ps.setInt(4, movie.getYear());
            ps.setDate(5, movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null);
            ps.setString(6, movie.getGenre());
            ps.setDouble(7, movie.getRating()); // rating 바인딩
            ps.setDouble(8, movie.getviolence_score_avg());  // violence_score_avg 바인딩
            ps.setString(9, movie.getOverview());
            ps.setString(10, movie.getPosterPath());

            int rowsAffected = ps.executeUpdate();
            logger.info("DB에 영화 '{}' 저장 완료. {}개 행 영향받음.", movie.getTitle(), rowsAffected);

        } catch (SQLException e) {
            logger.error("DB에 영화 '{}' 저장 중 오류 발생: {}", movie.getTitle(), e.getMessage(), e);
            throw new RuntimeException("영화 저장 실패", e);
        }
    }

    public void update(movie movie) {
        logger.debug("movieRepository.update() 호출: 영화 ID {} 업데이트 시도.", movie.getId());

        String sql = "UPDATE movies SET api_id=?, title=?, director=?, year=?, release_date=?, genre=?, rating=?, violence_score_avg=?, overview=?, poster_path=? WHERE id=?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, movie.getApiId());
            ps.setString(2, movie.getTitle());
            ps.setString(3, movie.getDirector());
            ps.setInt(4, movie.getYear());
            ps.setDate(5, movie.getReleaseDate() != null ? Date.valueOf(movie.getReleaseDate()) : null);
            ps.setString(6, movie.getGenre());
            ps.setDouble(7, movie.getRating()); // rating 바인딩
            ps.setDouble(8, movie.getviolence_score_avg());  
            ps.setString(9, movie.getOverview());
            ps.setString(10, movie.getPosterPath());
            ps.setLong(11, movie.getId()); 

            int rowsAffected = ps.executeUpdate();
            logger.info("DB에서 영화 ID {} 업데이트 완료. {}개 행 영향받음.", movie.getId(), rowsAffected);

        } catch (SQLException e) {
            logger.error("DB 영화 ID {} 업데이트 중 오류 발생: {}", movie.getId(), e.getMessage(), e);
            throw new RuntimeException("영화 업데이트 실패", e);
        }
    }

    public void delete(Long id) {
        logger.debug("movieRepository.delete({}) 호출: DB에서 영화 삭제 시도.", id);
        String sql = "DELETE FROM movies WHERE id=?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, id);
            int rowsAffected = ps.executeUpdate();
            logger.info("DB에서 영화 ID {} 삭제 완료. {}개 행 영향받음.", id, rowsAffected);

        } catch (SQLException e) {
            logger.error("DB 영화 ID {} 삭제 중 오류 발생: {}", id, e.getMessage(), e);
            throw new RuntimeException("영화 삭제 실패", e);
        }
    }
}