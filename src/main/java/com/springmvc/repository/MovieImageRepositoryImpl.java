package com.springmvc.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.MovieImage;

@Repository
public class MovieImageRepositoryImpl implements MovieImageRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<MovieImage> rowMapper = new RowMapper<MovieImage>() {
        public MovieImage mapRow(ResultSet rs, int rowNum) throws SQLException {
            MovieImage image = new MovieImage();
            image.setId(rs.getLong("id"));
            image.setMovieId(rs.getLong("movie_id"));
            image.setImageUrl(rs.getString("image_url"));
            image.setType(rs.getString("type"));
            image.setSortOrder(rs.getInt("sort_order"));
            image.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            return image;
        }
    };

    @Override
    public List<MovieImage> findImagesByMovieId(Long movieId) {
        String sql = "SELECT * FROM movie_images WHERE movie_id = ? ORDER BY sort_order ASC";
        return jdbcTemplate.query(sql, rowMapper, movieId);
    }

    @Override
    public void saveImages(List<MovieImage> images) {
        String sql = "INSERT INTO movie_images (movie_id, image_url, type, sort_order) VALUES (?, ?, ?, ?)";
        for (MovieImage img : images) {
            jdbcTemplate.update(sql, img.getMovieId(), img.getImageUrl(), img.getType(), img.getSortOrder());
        }
    }

    @Override
    public void deleteImagesByMovieId(Long movieId) {
        String sql = "DELETE FROM movie_images WHERE movie_id = ?";
        jdbcTemplate.update(sql, movieId);
    }
}
