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
    rating DECIMAL(3, 1) DEFAULT 0.0, -- (평균 만족도 별점 )
    overview TEXT, -- (영화 소개페이지)
    poster_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6. 데이터 확인
SELECT * FROM member;
SELECT * FROM movies;

-- 7. (필요할 때) 테이블 지우기
DROP TABLE member;
DROP TABLE movies;