package com.springmvc.domain;

// 사용자가 남긴 '개별 리뷰 점수'만을 담기 위한 DTO
public class UserReviewScoreDTO {

    private Integer userRating;
    private Integer violenceScore;
    private Integer horrorScore;
    private Integer sexualScore;

    // 기본 생성자
    public UserReviewScoreDTO() {
    }

    // Getters and Setters
    public Integer getUserRating() {
        return userRating;
    }

    public void setUserRating(Integer userRating) {
        this.userRating = userRating;
    }

    public Integer getViolenceScore() {
        return violenceScore;
    }

    public void setViolenceScore(Integer violenceScore) {
        this.violenceScore = violenceScore;
    }

    public Integer getHorrorScore() {
        return horrorScore;
    }

    public void setHorrorScore(Integer horrorScore) {
        this.horrorScore = horrorScore;
    }

    public Integer getSexualScore() {
        return sexualScore;
    }

    public void setSexualScore(Integer sexualScore) {
        this.sexualScore = sexualScore;
    }
}