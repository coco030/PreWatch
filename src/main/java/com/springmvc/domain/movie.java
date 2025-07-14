package com.springmvc.domain;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class movie {
    private Long id;
    private String apiId;
    private String title;
    private String director;
    private int year;
    private LocalDate releaseDate;
    private String genre;
    private double rating;
    private String violence_score_avg;
    private String overview;
    private String posterPath; // posterPath 필드 확인
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public movie() {}

    public movie(Long id, String title, String director, int year, String genre) {
        this.id = id;
        this.title = title;
        this.director = director;
        this.year = year;
        this.genre = genre;
    }

    public movie(Long id, String apiId, String title, String director, int year,
                 LocalDate releaseDate, String genre, double rating, String review,
                 String overview, String posterPath, // posterPath 생성자 파라미터 확인
                 LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.apiId = apiId;
        this.title = title;
        this.director = director;
        this.year = year;
        this.releaseDate = releaseDate;
        this.genre = genre;
        this.rating = rating;
        this.violence_score_avg = violence_score_avg;
        this.overview = overview;
        this.posterPath = posterPath; // 할당 확인
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public movie(String apiId, String title, String director, int year,
                 LocalDate releaseDate, String genre, String overview, String posterPath) { // posterPath 생성자 파라미터 확인
        this.apiId = apiId;
        this.title = title;
        this.director = director;
        this.year = year;
        this.releaseDate = releaseDate;
        this.genre = genre;
        this.overview = overview;
        this.posterPath = posterPath; // 할당 확인
    }

    // --- posterPath에 대한 Getter와 Setter 추가 ---
    public String getPosterPath() {
        return posterPath;
    }

    public void setPosterPath(String posterPath) {
        this.posterPath = posterPath;
    }

    // --- 다른 필드 Getter/Setter 유지 ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getApiId() { return apiId; }
    public void setApiId(String apiId) { this.apiId = apiId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public LocalDate getReleaseDate() { return releaseDate; }
    public void setReleaseDate(LocalDate releaseDate) { this.releaseDate = releaseDate; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public String getviolence_score_avg() { return violence_score_avg; }
    public void setviolence_score_avg(String violence_score_avg) { this.violence_score_avg = violence_score_avg; }

    public String getOverview() { return overview; }
    public void setOverview(String overview) { this.overview = overview; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}