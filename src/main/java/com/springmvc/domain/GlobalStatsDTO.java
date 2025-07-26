// src/main/java/com/springmvc/domain/GlobalStatsDTO.java
package com.springmvc.domain;

public class GlobalStatsDTO {
    private long totalReviewContentCount;
    private long totalUserRatingCount;
    private long totalViolenceScoreCount;

    // Getters and Setters
    public long getTotalReviewContentCount() {
        return totalReviewContentCount;
    }

    public void setTotalReviewContentCount(long totalReviewContentCount) {
        this.totalReviewContentCount = totalReviewContentCount;
    }

    public long getTotalUserRatingCount() {
        return totalUserRatingCount;
    }

    public void setTotalUserRatingCount(long totalUserRatingCount) {
        this.totalUserRatingCount = totalUserRatingCount;
    }

    public long getTotalViolenceScoreCount() {
        return totalViolenceScoreCount;
    }

    public void setTotalViolenceScoreCount(long totalViolenceScoreCount) {
        this.totalViolenceScoreCount = totalViolenceScoreCount;
    }
}