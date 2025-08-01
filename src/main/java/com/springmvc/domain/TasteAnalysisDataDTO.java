package com.springmvc.domain;

// 취향 분석에 필요한 모든 데이터를 담는 전용 DTO
public class TasteAnalysisDataDTO {

    // 1. 내가 매긴 점수 (user_reviews 테이블)
    private Integer myUserRating;
    private Integer myViolenceScore;
    private Integer myHorrorScore;
    private Integer mySexualScore;

    // 2. 해당 영화의 전체 평균 점수 (movies, movie_stats 테이블)
    private Double movieAvgRating;
    private Double movieAvgViolence;
    private Double movieAvgHorror;
    private Double movieAvgSexual;
    
}