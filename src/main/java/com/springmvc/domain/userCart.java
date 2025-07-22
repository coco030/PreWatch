package com.springmvc.domain;

import java.time.LocalDateTime;

// UserCart 클래스: 사용자(Member)가 찜한 영화(Movie) 정보를 담는 도메인 클래스입니다.
// 데이터베이스의 'user_carts' 테이블과 1:1로 매핑됩니다.
// 목적: 어떤 회원이 어떤 영화를 찜했는지 기록하고 관리합니다.
public class userCart {
    private Long id;           // 찜 항목의 고유 ID (PRIMARY KEY, AUTO_INCREMENT)
    private String memberId;   // 찜한 회원의 ID (FOREIGN KEY to member.id)
    private Long movieId;      // 찜한 영화의 ID (FOREIGN KEY to movies.id)
    private LocalDateTime createdAt; // 찜한 시각

    // 기본 생성자
    public userCart() {}

    // 모든 필드를 포함하는 생성자
    public userCart(Long id, String memberId, Long movieId, LocalDateTime createdAt) {
        this.id = id;
        this.memberId = memberId;
        this.movieId = movieId;
        this.createdAt = createdAt;
    }

    // Getter/Setter
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "UserCart [id=" + id + ", memberId=" + memberId + ", movieId=" + movieId + ", createdAt=" + createdAt + "]";
    }
}