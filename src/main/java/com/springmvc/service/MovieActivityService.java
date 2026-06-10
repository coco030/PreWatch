package com.springmvc.service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.springmvc.domain.Movie;

@Service
public class MovieActivityService {

    private static final int RECENT_VIEWED_MOVIE_LIMIT = 3;
    private static final String CREATE_MOVIE_VIEW_ACTIVITY_SQL = """
        CREATE TABLE IF NOT EXISTS movie_view_activity (
            movie_id BIGINT PRIMARY KEY,
            view_count INT NOT NULL DEFAULT 1,
            last_viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
        )
        """;

    private final JdbcTemplate jdbcTemplate;
    private volatile boolean schemaChecked;

    public MovieActivityService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordDetailView(Long movieId) {
        if (movieId == null) {
            return;
        }

        ensureMovieViewActivityTable();
        String sql = """
            INSERT INTO movie_view_activity (movie_id, view_count, last_viewed_at)
            VALUES (?, 1, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE
                view_count = view_count + 1,
                last_viewed_at = CURRENT_TIMESTAMP
            """;
        jdbcTemplate.update(sql, movieId);
    }

    @Transactional(readOnly = true)
    public List<Movie> getRecentViewedMovies() {
        ensureMovieViewActivityTable();
        String sql = """
            SELECT m.id, m.api_id, m.title, m.poster_path, m.rated, m.rating, m.genre
            FROM movie_view_activity a
            JOIN movies m ON a.movie_id = m.id
            ORDER BY a.last_viewed_at DESC
            LIMIT ?
            """;
        return jdbcTemplate.query(sql, new RecentViewedMovieRowMapper(), RECENT_VIEWED_MOVIE_LIMIT);
    }

    private void ensureMovieViewActivityTable() {
        if (schemaChecked) {
            return;
        }

        synchronized (this) {
            if (schemaChecked) {
                return;
            }

            jdbcTemplate.execute(CREATE_MOVIE_VIEW_ACTIVITY_SQL);
            schemaChecked = true;
        }
    }

    private static class RecentViewedMovieRowMapper implements RowMapper<Movie> {
        @Override
        public Movie mapRow(ResultSet rs, int rowNum) throws SQLException {
            Movie movie = new Movie();
            movie.setId(rs.getLong("id"));
            movie.setApiId(rs.getString("api_id"));
            movie.setTitle(rs.getString("title"));
            movie.setPosterPath(rs.getString("poster_path"));
            movie.setRated(rs.getString("rated"));
            movie.setRating(rs.getDouble("rating"));
            movie.setGenre(rs.getString("genre"));
            return movie;
        }
    }
}
