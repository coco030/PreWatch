package com.springmvc.domain;

import java.io.Serializable; // Serializable 인터페이스 추가 (필요시)
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.format.annotation.DateTimeFormat;

// movie 클래스: 애플리케이션에서 관리하는 영화 정보를 담는 도메인 클래스.
// 목적: 영화 등록, 조회, 수정, 삭제 등 영화 관련 데이터 주고받기.
public class movie implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;              // 영화의 고유 ID (PRIMARY KEY)
    private String apiId;         // 외부 영화 API 고유 ID (예: OMDb의 "tt1234567")
    private String title;         // 영화 제목
    private String director;      // 영화 감독
    private int year;             // 영화 개봉 연도
    //
    @DateTimeFormat(pattern = "yyyy-MM-dd") // 25.07.26 coco030 추가
    //
    private LocalDate releaseDate; // 영화 개봉일
    private String genre;         // 영화 장르
    private double rating;        // 영화의 평균 만족도 평점 (0.0 ~ 10.0)
    private double violence_score_avg; // 영화의 평균 폭력성 점수 (0.0 ~ 10.0)
    private String overview;      // 영화 줄거리/설명
    private String posterPath;    // 영화 포스터 이미지 경로 또는 URL
    private LocalDateTime createdAt; // DB에 처음 저장된 시간
    private LocalDateTime updatedAt; // 마지막으로 업데이트된 시간
    private boolean isLiked; // ⭐ 추가: 현재 로그인된 사용자가 이 영화를 찜했는지 여부. (DB에는 저장되지 않고 뷰 계층에 데이터를 전달하기 위한 임시 필드)
    private int likeCount;   // ⭐ 추가: 찜 개수 (DB에 저장될 필드)
    // isRecommended 필드는 이 요구사항에서 movie 도메인에서 제거됩니다. (7-24 오후12:41 추가 된 코드)

    // 기본 생성자: 매개변수 없이 객체 생성.
    public movie() {
        this.rating = 0.0;
        this.violence_score_avg = 0.0;
        this.likeCount = 0;
        this.isLiked = false;
        // isRecommended 초기화 로직 제거 (7-24 오후12:41 추가 된 코드)
    }

    // 일부 필드만 포함하는 생성자.
    public movie(Long id, String title, String director, int year, String genre) {
        this(); // 기본 생성자 호출하여 필드 초기화
        this.id = id;
        this.title = title;
        this.director = director;
        this.year = year;
        this.genre = genre;
    }

    // 모든 필드를 포함하는 생성자.
    // likeCount 포함하도록 수정
    public movie(Long id, String apiId, String title, String director, int year, LocalDate releaseDate, String genre, double rating, double violence_score_avg, String overview, String posterPath,
                 LocalDateTime createdAt, LocalDateTime updatedAt, int likeCount) { // isRecommended 파라미터 제거 (7-24 오후12:41 추가 된 코드)
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
        // isRecommended 초기화 로직 제거 (7-24 오후12:41 추가 된 코드)
    }

    // API에서 가져온 필수 정보를 초기화하는 생성자.
    // likeCount 포함하도록 수정 (API에서 가져올 때는 기본값 0)
    public movie(String apiId, String title, String director, int year,
                 LocalDate releaseDate, String genre, String overview, String posterPath) {
        this(); // 기본 생성자 호출하여 필드 초기화
        this.apiId = apiId;
        this.title = title;
        this.director = director;
        this.year = year;
        this.releaseDate = releaseDate;
        this.genre = genre;
        this.overview = overview;
        this.posterPath = posterPath;
    }

    // Getter/Setter: 각 필드에 대한 값 읽기/쓰기 접근 메서드.
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

    public boolean isLiked() {
        return isLiked;
    }

    public void setIsLiked(boolean isLiked) {
        this.isLiked = isLiked;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    // isRecommended 필드에 대한 Getter/Setter 제거 (7-24 오후12:41 추가 된 코드)
    
    // 25.07.26 coco030 오후 7시 9분
    private Integer dday;

    public Integer getDday() {
        return dday;
    }

    public void setDday(Integer dday) {
        this.dday = dday;
    }
    
}