package com.springmvc.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.springmvc.domain.UserRating;
import com.springmvc.service.UserRatingService;

@RestController
@RequestMapping("/rating")
public class UserRatingController {

    @Autowired
    private UserRatingService service;

    @PostMapping("/submit")
    public ResponseEntity<?> rate(@RequestParam String memberId,
                                  @RequestParam Long movieId,
                                  @RequestParam int rating) {
        if (rating >= 1 && rating <= 10) {
            service.rate(memberId, movieId, rating);
            return ResponseEntity.ok("rated");
        } else if (rating == 0) {
            service.delete(memberId, movieId);
            return ResponseEntity.ok("deleted");
        } else {
            return ResponseEntity.badRequest().body("invalid rating");
        }
    }

    @GetMapping("/get")
    public ResponseEntity<UserRating> getRating(@RequestParam String memberId,
                                                @RequestParam Long movieId) {
        UserRating rating = service.get(memberId, movieId);
        return ResponseEntity.ok(rating);
    }
}