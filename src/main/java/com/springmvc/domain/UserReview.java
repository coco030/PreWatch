package com.springmvc.domain;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class UserReview {

    private Long id;                 // PK (AUTO_INCREMENT)
    private String memberId;         // FK → member.id (VARCHAR)
    private Long movieId;            // FK → movies.id (BIGINT)
    private Integer userRating;      // 별점 1~10
    private Integer violenceScore;   // 폭력성 1~10
    private Integer horrorScore;      // 호러 1~10
    private Integer sexualScore;   // 선정성 1~10
    private String reviewContent;    // 텍스트
    private String tags;             // 쉼표 구분 태그
    private LocalDateTime createdAt; // INSERT 시점에 DB가 자동 입력

    // 기본 생성자
    public UserReview() {}
    // 전체 파라미터 생성자 - 새로운 리뷰 작성 시 사용
    public UserReview(String memberId, Long movieId, Integer userRating, Integer violenceScore,
			Integer horrorScore, Integer sexualScore, String reviewContent, String tags) {
		this.memberId = memberId;
		this.movieId = movieId;
		this.userRating = userRating;
		this.violenceScore = violenceScore;
		this.horrorScore = horrorScore;
		this.sexualScore = sexualScore;
		this.reviewContent = reviewContent;
		this.tags = tags;
		// id, createdAt은 DB에서 자동 생성되므로 생성자에서 제외
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
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public Long getMovieId() {
		return movieId;
	}

	public void setMovieId(Long movieId) {
		this.movieId = movieId;
	}

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

	public String getReviewContent() {
		return reviewContent;
	}

	public void setReviewContent(String reviewContent) {
		this.reviewContent = reviewContent;
	}

	public String getTags() {
		return tags;
	}

	public void setTags(String tags) {
		this.tags = tags;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
	

	@Override
	public String toString() {
		return "UserReview [id=" + id + ", memberId=" + memberId + ", movieId=" + movieId + ", userRating=" + userRating
				+ ", violenceScore=" + violenceScore + ", horrorScore=" + horrorScore + ", sexualScore=" + sexualScore
				+ ", reviewContent=" + reviewContent + ", tags=" + tags + ", createdAt=" + createdAt + "]";
	}
	
	// ,로 태그 구분을 위해서 추가한 것
	public List<String> getTagList() {
	    return tags != null ? Arrays.asList(tags.split(",")) : Collections.emptyList();
	}
	

}