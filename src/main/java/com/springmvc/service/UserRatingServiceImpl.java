package com.springmvc.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.UserRating;
import com.springmvc.repository.UserRatingRepository;

@Service
public class UserRatingServiceImpl implements UserRatingService {

    @Autowired
    private UserRatingRepository repository;

    @Override
    public void rate(String memberId, Long movieId, int rating) {
        repository.saveOrUpdate(new UserRating(memberId, movieId, rating));
    }

    @Override
    public void delete(String memberId, Long movieId) {
        repository.delete(memberId, movieId);
    }

    @Override
    public UserRating get(String memberId, Long movieId) {
        return repository.findByMemberAndMovie(memberId, movieId);
    }
}
