package com.springmvc.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.springmvc.domain.UserRating;

@Repository
public class UserRatingRepositoryImpl implements UserRatingRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Override
    public void saveOrUpdate(UserRating rating) {
        String sql = "INSERT INTO user_reviews (member_id, movie_id, user_rating) " +
                     "VALUES (?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE user_rating = ?";
        jdbcTemplate.update(sql, rating.getMemberId(), rating.getMovieId(), rating.getRating(), rating.getRating());
    }

    @Override
    public void delete(String memberId, Long movieId) {
        String sql = "UPDATE user_reviews SET user_rating = NULL WHERE member_id = ? AND movie_id = ?";
        jdbcTemplate.update(sql, memberId, movieId);
    }

    @Override
    public UserRating findByMemberAndMovie(String memberId, Long movieId) {
        String sql = "SELECT user_rating FROM user_reviews WHERE member_id = ? AND movie_id = ?";
        try {
            Integer rating = jdbcTemplate.queryForObject(sql, Integer.class, memberId, movieId);
            return (rating != null) ? new UserRating(memberId, movieId, rating) : null;
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }
}