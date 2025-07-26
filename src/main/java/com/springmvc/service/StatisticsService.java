// src/main/java/com/springmvc/service/StatisticsService.java
package com.springmvc.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.springmvc.domain.GlobalStatsDTO;
import com.springmvc.repository.UserReviewRepository;

@Service
public class StatisticsService {

    @Autowired
    private UserReviewRepository userReviewRepository;

    public GlobalStatsDTO getGlobalStats() {
        GlobalStatsDTO stats = new GlobalStatsDTO();
        stats.setTotalReviewContentCount(userReviewRepository.getTotalReviewContentCount());
        stats.setTotalUserRatingCount(userReviewRepository.getTotalUserRatingCount());
        stats.setTotalViolenceScoreCount(userReviewRepository.getTotalViolenceScoreCount());
        return stats;
    }
}