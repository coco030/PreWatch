package com.springmvc.domain;

import java.io.Serializable;
import java.time.LocalDateTime;

public class MovieImage implements Serializable {
    private Long id;
    private Long movieId;
    private String imageUrl;
    private String type;
    private int sortOrder;
    private LocalDateTime createdAt;

    // 기본 생성자
    public MovieImage() {}

    // 생성자 (필요 시)
    public MovieImage(Long movieId, String imageUrl, String type, int sortOrder) {
        this.movieId = movieId;
        this.imageUrl = imageUrl;
        this.type = type;
        this.sortOrder = sortOrder;
    }

    // Getter & Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getMovieId() { return movieId; }
    public void setMovieId(Long movieId) { this.movieId = movieId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
