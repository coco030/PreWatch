package com.springmvc.domain;

// 취향 분석에 필요한 모든 데이터를 담는 전용 DTO
public class TasteAnalysisDataDTO {
	public TasteAnalysisDataDTO() {}
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
    
	public Integer getMyUserRating() {
		return myUserRating;
	}
	  
	
	public TasteAnalysisDataDTO(Integer myUserRating, Integer myViolenceScore, Integer myHorrorScore,
			Integer mySexualScore, Double movieAvgRating, Double movieAvgViolence, Double movieAvgHorror,
			Double movieAvgSexual) {
		super();
		this.myUserRating = myUserRating;
		this.myViolenceScore = myViolenceScore;
		this.myHorrorScore = myHorrorScore;
		this.mySexualScore = mySexualScore;
		this.movieAvgRating = movieAvgRating;
		this.movieAvgViolence = movieAvgViolence;
		this.movieAvgHorror = movieAvgHorror;
		this.movieAvgSexual = movieAvgSexual;
	}


	public TasteAnalysisDataDTO(UserReviewScoreDTO review, StatDTO movieStats) {
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
	@Override
	public String toString() {
		return "TasteAnalysisDataDTO [myUserRating=" + myUserRating + ", myViolenceScore=" + myViolenceScore
				+ ", myHorrorScore=" + myHorrorScore + ", mySexualScore=" + mySexualScore + ", movieAvgRating="
				+ movieAvgRating + ", movieAvgViolence=" + movieAvgViolence + ", movieAvgHorror=" + movieAvgHorror
				+ ", movieAvgSexual=" + movieAvgSexual + "]";
	}
    
    
}