-- 1. 데이터베이스 만들기
CREATE DATABASE prewatch_member_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 2. 사용할 DB 선택
USE prewatch_member_db;

-- 3. 테이블 생성
CREATE TABLE member (
    id VARCHAR(50) PRIMARY KEY,
<<<<<<< HEAD
    password VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'   --   회원의 status(ACTIVE, INACTIVE, DELETED, DORMANT(휴면) 관리를 위해)
=======
    password VARCHAR(100) NOT NULL
>>>>>>> 4bceb7925953eb4af9533b02996141ec23f73d07
);

-- 4. 회원 조회
SELECT * FROM  member;
