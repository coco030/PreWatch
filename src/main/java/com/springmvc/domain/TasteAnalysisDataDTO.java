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
    
    // 3. 어떤 영화에 대한 분석 데이터인지 식별하기 위한 ID
    private Long movieId; // 변수명과 타입을 올바르게 수정

    public TasteAnalysisDataDTO() {}

    // 모든 필드를 받는 생성자 (선택사항, 필요하다면 사용)
    public TasteAnalysisDataDTO(Integer myUserRating, Integer myViolenceScore, Integer myHorrorScore,
            Integer mySexualScore, Double movieAvgRating, Double movieAvgViolence, Double movieAvgHorror,
            Double movieAvgSexual, Long movieId) {
        this.myUserRating = myUserRating;
        this.myViolenceScore = myViolenceScore;
        this.myHorrorScore = myHorrorScore;
        this.mySexualScore = mySexualScore;
        this.movieAvgRating = movieAvgRating;
        this.movieAvgViolence = movieAvgViolence;
        this.movieAvgHorror = movieAvgHorror;
        this.movieAvgSexual = movieAvgSexual;
        this.movieId = movieId;
    }
    
    // Getter 및 Setter 메서드 (표준 규칙에 맞게 수정)
    public Integer getMyUserRating() {
        return myUserRating;
    }
    public void setMyUserRating(Integer myUserRating) {
        this.myUserRating = myUserRating;
    }
    public Integer getMyViolenceScore() {
        return myViolenceScore;
    }
    public void setMyViolenceScore(Integer myViolenceScore) {
        this.myViolenceScore = myViolenceScore;
    }
    public Integer getMyHorrorScore() {
        return myHorrorScore;
    }
    public void setMyHorrorScore(Integer myHorrorScore) {
        this.myHorrorScore = myHorrorScore;
    }
    public Integer getMySexualScore() {
        return mySexualScore;
    }
    public void setMySexualScore(Integer mySexualScore) {
        this.mySexualScore = mySexualScore;
    }
    public Double getMovieAvgRating() {
        return movieAvgRating;
    }
    public void setMovieAvgRating(Double movieAvgRating) {
        this.movieAvgRating = movieAvgRating;
    }
    public Double getMovieAvgViolence() {
        return movieAvgViolence;
    }
    public void setMovieAvgViolence(Double movieAvgViolence) {
        this.movieAvgViolence = movieAvgViolence;
    }
    public Double getMovieAvgHorror() {
        return movieAvgHorror;
    }
    public void setMovieAvgHorror(Double movieAvgHorror) {
        this.movieAvgHorror = movieAvgHorror;
    }
    public Double getMovieAvgSexual() {
        return movieAvgSexual;
    }
    public void setMovieAvgSexual(Double movieAvgSexual) {
        this.movieAvgSexual = movieAvgSexual;
    }
    public Long getMovieId() {
        return movieId;
    }
    public void setMovieId(Long movieId) {
        this.movieId = movieId;
    }

    @Override
    public String toString() {
        return "TasteAnalysisDataDTO [myUserRating=" + myUserRating + ", myViolenceScore=" + myViolenceScore
                + ", myHorrorScore=" + myHorrorScore + ", mySexualScore=" + mySexualScore + ", movieAvgRating="
                + movieAvgRating + ", movieAvgViolence=" + movieAvgViolence + ", movieAvgHorror=" + movieAvgHorror
                + ", movieAvgSexual=" + movieAvgSexual + ", movieId=" + movieId + "]";
    }
}