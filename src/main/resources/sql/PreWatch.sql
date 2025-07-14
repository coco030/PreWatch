-- 1. 데이터베이스 만들기 (처음 한 번만 실행)
CREATE DATABASE IF NOT EXISTS prewatch_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 2. 사용할 DB 선택
USE prewatch_db;

-- 3. 회원 테이블 생성
CREATE TABLE member (
    id VARCHAR(50) PRIMARY KEY,
    password VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

-- 4. 영화 테이블 생성
CREATE TABLE movies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    api_id VARCHAR(255) UNIQUE,
    title VARCHAR(255) NOT NULL,
    director VARCHAR(255),
    release_date DATE,
    year INT,
    genre VARCHAR(255),
    rating DECIMAL(3, 1) DEFAULT 0.0, -- (평균 만족도 별점)
    overview TEXT, -- (영화 소개페이지)
    poster_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- 5. 사용자가 작성한 게 저장되는 테이블 (user_reviews)
-- [별점/폭력성 점수/리뷰 내용/태그]를 모두 저장
CREATE TABLE user_reviews (
    -- 기본 키
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    movie_id BIGINT NOT NULL,  
    -- 실제 평가 데이터
    user_rating INT,    -- 별점 (1~10) / 영화 테이블의 rating과 헷갈리지 않게 수정
    violence_score INT,    -- 폭력성 점수 (1~10)
    review_content TEXT, -- 리뷰 텍스트
    tags VARCHAR(255),   -- 태그 (쉼표로 구분된 텍스트)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (member_id, movie_id),   -- 한 명의 유저는 한 영화에 대해 리뷰를 하나만 남길 수 있도록 강제
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);


-- 데이터 확인
SELECT * FROM member;
SELECT * FROM movies;
SELECT * FROM user_reviews;

-- 필요할 때 테이블 지우기 (자식 테이블부터 삭제)
DROP TABLE IF EXISTS user_reviews;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS movies;