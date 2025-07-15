package com.springmvc.domain;

public class UserRating {
    private String memberId; // FK
    private Long movieId;    // FK
    private int rating;      // 1~5

    public UserRating() {}

    public UserRating(String memberId, Long movieId, int rating) {
        this.memberId = memberId;
        this.movieId = movieId;
        this.rating = rating;
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

	public int getRating() {
		return rating;
	}

	public void setRating(int rating) {
		this.rating = rating;
	}

	@Override
	public String toString() {
		return "UserRating [memberId=" + memberId + ", movieId=" + movieId + ", rating=" + rating + "]";
	}
}