package com.springmvc.domain;

import java.time.LocalDateTime;

public class AdminBannerMovie { // (7-24 오후12:41 추가 된 코드)
    private Long id; // (7-24 오후12:41 추가 된 코드)
    private Long movieId; // (7-24 오후12:41 추가 된 코드)
    private Integer displayOrder; // (7-24 오후12:41 추가 된 코드)
    private LocalDateTime createdAt; // (7-24 오후12:41 추가 된 코드)

    // 편의상 movie 상세 정보를 담을 필드 (DB 컬럼 아님) (7-24 오후12:41 추가 된 코드)
    private movie movieDetail; // (7-24 오후12:41 추가 된 코드)

    public AdminBannerMovie() {} // (7-24 오후12:41 추가 된 코드)

    // Getters and Setters
    public Long getId() { return id; } // (7-24 오후12:41 추가 된 코드)
    public void setId(Long id) { this.id = id; } // (7-24 오후12:41 추가 된 코드)
    public Long getMovieId() { return movieId; } // (7-24 오후12:41 추가 된 코드)
    public void setMovieId(Long movieId) { this.movieId = movieId; } // (7-24 오후12:41 추가 된 코드)
    public Integer getDisplayOrder() { return displayOrder; } // (7-24 오후12:41 추가 된 코드)
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; } // (7-24 오후12:41 추가 된 코드)
    public LocalDateTime getCreatedAt() { return createdAt; } // (7-24 오후12:41 추가 된 코드)
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; } // (7-24 오후12:41 추가 된 코드)
    public movie getMovieDetail() { return movieDetail; } // (7-24 오후12:41 추가 된 코드)
    public void setMovieDetail(movie movieDetail) { this.movieDetail = movieDetail; } // (7-24 오후12:41 추가 된 코드)
}
