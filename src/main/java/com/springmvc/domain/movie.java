package com.springmvc.domain;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

public class movie implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String apiId;
    private String title;
    private String director;
    private int year;
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate releaseDate;
    private String genre;
    private double rating;
    private double violence_score_avg;
    private String overview;
    private String posterPath;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isLiked;
    private int likeCount;
    private String runtime;
    private String rated;
    private Integer dday;
    private String backdropPath; //25.08.07 coco030
    private double tmdbRating; // TMDB 평점을 화면에 보여주기 위한 임시 필드 (DB 저장 X)

    public String getFormattedReleaseDate() {
        if (releaseDate != null) {
            return releaseDate.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
        } else {
            return "";
        }
    }

    public movie() {
        this.rating = 0.0;
        this.violence_score_avg = 0.0;
        this.likeCount = 0;
        this.isLiked = false;
    }

    public movie(Long id, String title, String director, int year, String genre) {
        this();
        this.id = id;
        this.title = title;
        this.director = director;
        this.year = year;
        this.genre = genre;
    }

    public movie(Long id, String apiId, String title, String director, int year, LocalDate releaseDate, String genre, double rating, double violence_score_avg, String overview, String posterPath,
                 LocalDateTime createdAt, LocalDateTime updatedAt, int likeCount, String runtime, String rated) {
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
        this.posterPath = posterPath;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.likeCount = likeCount;
        this.runtime = runtime;
        this.rated = rated;    
    }

    public movie(String apiId, String title, String director, int year,
                 LocalDate releaseDate, String genre, String overview, String posterPath, String runtime, String rated) {
        this();
        this.apiId = apiId;
        this.title = title;
        this.director = director;
        this.year = year;
        this.releaseDate = releaseDate;
        this.genre = genre;
        this.overview = overview;
        this.posterPath = posterPath;
        this.runtime = runtime;
        this.rated = rated;
    }

    public String getPosterPath() { return posterPath; }
    public void setPosterPath(String posterPath) { this.posterPath = posterPath; }

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

    public double getViolence_score_avg() { return violence_score_avg; }
    public void setViolence_score_avg(double violence_score_avg) { this.violence_score_avg = violence_score_avg; }

    public String getOverview() { return overview; }
    public void setOverview(String overview) { this.overview = overview; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public boolean isLiked() { return isLiked; }
    public void setIsLiked(boolean isLiked) { this.isLiked = isLiked; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public Integer getDday() { return dday; }
    public void setDday(Integer dday) { this.dday = dday; }

    public String getRuntime() { return runtime; }
    public void setRuntime(String runtime) { this.runtime = runtime; }

    public String getRated() { return rated; }
    public void setRated(String rated) { this.rated = rated; }

    //25.08.07 coco030
    public String getBackdropPath() {
        return backdropPath;
    }

  //25.08.07 coco030
    public void setBackdropPath(String backdropPath) {
        this.backdropPath = backdropPath;
    }
    
    // 25.12.03
    public double getTmdbRating() {return tmdbRating;}
    public void setTmdbRating(double tmdbRating) {
    	this.tmdbRating = tmdbRating;}
	
	
}