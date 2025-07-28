// 홈 화면 하단에 뜨는 글로벌 sum 결과 + 모든 통계 보여주는 곳의 정보가 담김
// src/main/java/com/springmvc/domain/StatDTO.java
package com.springmvc.domain;

public class StatDTO {
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
    
    // 여기서부터 나머지 스텟 추가
}