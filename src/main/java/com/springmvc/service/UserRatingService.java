package com.springmvc.service;

import com.springmvc.domain.UserRating;

public interface UserRatingService {
    void rate(String memberId, Long movieId, int rating);
    void delete(String memberId, Long movieId);
    UserRating get(String memberId, Long movieId);
}