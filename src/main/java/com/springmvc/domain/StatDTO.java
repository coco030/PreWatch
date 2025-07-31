// 홈 화면 하단에 뜨는 글로벌 sum 결과 + 모든 통계 보여주는 곳의 정보가 담김
// src/main/java/com/springmvc/domain/StatDTO.java
package com.springmvc.domain;

import java.util.List;

public class StatDTO {
	
	// 생성자, Getter, Setter
    public StatDTO() {}
    
    // 홈 하단의 전체 통계용
    private long totalReviewContentCount;
    private long totalUserRatingCount;
    private long totalViolenceScoreCount;

    // 1. 특정 영화의 정보
    private long movieId;
    private String title;

    // 2. 특정 영화의 통계 점수 (두 테이블에서 가져옴)
    private double userRatingAvg;       // movies.rating
    private double violenceScoreAvg;    // movies.violence_score_avg
    private double horrorScoreAvg;      // movie_stats.horror_score_avg
    private double sexualScoreAvg;      // movie_stats.sexual_score_avg
    private int reviewCount;            // movie_stats.review_count

    // 3. 특정 영화의 장르 목록 (movie_genres 테이블에서 가져옴)
    private List<String> genres;

    // 4. 비교 대상: 장르 평균 점수 (동적으로 계산)
    private double genreRatingAvg;
    private double genreViolenceScoreAvg;
    private double genreHorrorScoreAvg;
    private double genreSexualScoreAvg;
    
    
    // Getter 및 Setter 메서드
    public long getMovieId() { return movieId; }
    public void setMovieId(long movieId) { this.movieId = movieId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public double getUserRatingAvg() { return userRatingAvg; }
    public void setUserRatingAvg(double userRatingAvg) { this.userRatingAvg = userRatingAvg; }
    public double getViolenceScoreAvg() { return violenceScoreAvg; }
    public void setViolenceScoreAvg(double violenceScoreAvg) { this.violenceScoreAvg = violenceScoreAvg; }
    public double getHorrorScoreAvg() { return horrorScoreAvg; }
    public void setHorrorScoreAvg(double horrorScoreAvg) { this.horrorScoreAvg = horrorScoreAvg; }
    public double getSexualScoreAvg() { return sexualScoreAvg; }
    public void setSexualScoreAvg(double sexualScoreAvg) { this.sexualScoreAvg = sexualScoreAvg; }
    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }
    public List<String> getGenres() { return genres; }
    public void setGenres(List<String> genres) { this.genres = genres; }
    public double getGenreRatingAvg() { return genreRatingAvg; }
    public void setGenreRatingAvg(double genreRatingAvg) { this.genreRatingAvg = genreRatingAvg; }
    public double getGenreViolenceScoreAvg() { return genreViolenceScoreAvg; }
    public void setGenreViolenceScoreAvg(double genreViolenceScoreAvg) { this.genreViolenceScoreAvg = genreViolenceScoreAvg; }
    public double getGenreHorrorScoreAvg() { return genreHorrorScoreAvg; }
    public void setGenreHorrorScoreAvg(double genreHorrorScoreAvg) { this.genreHorrorScoreAvg = genreHorrorScoreAvg; }
    public double getGenreSexualScoreAvg() { return genreSexualScoreAvg; }
    public void setGenreSexualScoreAvg(double genreSexualScoreAvg) { this.genreSexualScoreAvg = genreSexualScoreAvg; }



    // 홈 하단의 전체 통계용 Getters and Setters
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
    // 홈 하단의 전체 통계용 Getters and Setters 끝
}
    
   