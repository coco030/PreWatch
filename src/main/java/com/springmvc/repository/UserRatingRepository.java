package com.springmvc.repository;

import com.springmvc.domain.UserRating;

public interface UserRatingRepository {
    void saveOrUpdate(UserRating rating);
    void delete(String memberId, Long movieId);
    UserRating findByMemberAndMovie(String memberId, Long movieId);
}
