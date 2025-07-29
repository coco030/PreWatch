package com.springmvc.domain;

public class RecentCommentDTO {
    private String memberId; // 사용자 이름
    private int userRating; // 별점
    private String movieName; // 영화 이름
    private String reviewContent; // 코멘트 내용
    private String posterPath; // 영화 포스터 경로
    private int newLikeCount; // 찜 개수 (좋아요 수)
    private Long movieId; // + 25.07.29 coco030 추가

    public RecentCommentDTO() {
    }

    
    // movieId; + 25.07.29 coco030 추가
    public RecentCommentDTO(String memberId, int userRating, String movieName, String reviewContent, String posterPath, int newLikeCount, Long movieId) {
        this.memberId = memberId;
        this.userRating = userRating;
        this.movieName = movieName;
        this.reviewContent = reviewContent;
        this.posterPath = posterPath;
        this.newLikeCount = newLikeCount;
        this.movieId = movieId;
    }

    public Long getMovieId() {
        return movieId;
    }

    public void setMovieId(Long movieId) {
        this.movieId = movieId;
    }
    
    //  // movieId; + 25.07.29 coco030 추가 끝

    // Getter 및 Setter 메서드
    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public int getUserRating() {
        return userRating;
    }

    public void setUserRating(int userRating) {
        this.userRating = userRating;
    }

    public String getMovieName() {
        return movieName;
    }

    public void setMovieName(String movieName) {
        this.movieName = movieName;
    }

    public String getReviewContent() {
        return reviewContent;
    }

    public void setReviewContent(String reviewContent) {
        this.reviewContent = reviewContent;
    }

    public String getPosterPath() {
        return posterPath;
    }

    public void setPosterPath(String posterPath) {
        this.posterPath = posterPath;
    }

    public int getNewLikeCount() {
        return newLikeCount;
    }

    public void setNewLikeCount(int newLikeCount) {
        this.newLikeCount = newLikeCount;
    }

    @Override
    public String toString() {
        return "RecentCommentDTO{" +
               "memberId='" + memberId + '\'' +
               ", userRating=" + userRating +
               ", movieName='" + movieName + '\'' +
               ", reviewContent='" + reviewContent + '\'' +
               ", posterPath='" + posterPath + '\'' +
               ", newLikeCount=" + newLikeCount +
               '}';
    }
}