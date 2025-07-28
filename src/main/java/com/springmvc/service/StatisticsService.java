// src/main/java/com/springmvc/service/StatisticsService.java
// 글로벌 합계 때문에 있는 페이지 (홈 하단)
package com.springmvc.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.springmvc.domain.StatDTO;
import com.springmvc.repository.UserReviewRepository;

@Service
public class StatisticsService {

    @Autowired
    private UserReviewRepository userReviewRepository;

    public StatDTO getGlobalStats() {
        StatDTO stats = new StatDTO();
        stats.setTotalReviewContentCount(userReviewRepository.getTotalReviewContentCount());
        stats.setTotalUserRatingCount(userReviewRepository.getTotalUserRatingCount());
        stats.setTotalViolenceScoreCount(userReviewRepository.getTotalViolenceScoreCount());
        return stats;
    }
}