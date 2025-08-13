 

-- 1. 데이터베이스 만들기
CREATE DATABASE IF NOT EXISTS prewatch_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 2. 사용할 DB 선택
USE prewatch_db;

-- 3. 기존 테이블 삭제 (자식 → 부모 순서)
DROP TABLE IF EXISTS movie_warning_tags; 
DROP TABLE IF EXISTS warning_tags;   -- 무비 테이블이 부모 
DROP TABLE IF EXISTS movie_genres;          -- 영화-장르 매핑
DROP TABLE IF EXISTS movie_actors;          -- 영화-배우 연결
DROP TABLE IF EXISTS actors;                -- 배우 테이블
DROP TABLE IF EXISTS movie_images;          -- 영화-이미지 연결
DROP TABLE IF EXISTS admin_banner_movies;   -- 관리자 추천 배너
DROP TABLE IF EXISTS user_reviews;          -- 유저 리뷰
DROP TABLE IF EXISTS user_carts;            -- 유저 찜
DROP TABLE IF EXISTS movie_stats;           -- 영화별 통계
DROP TABLE IF EXISTS movies;                -- 영화 테이블
DROP TABLE IF EXISTS member;                -- 회원 테이블

-- 4. 회원 테이블
CREATE TABLE member (
    id VARCHAR(50) PRIMARY KEY,
    password VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    role VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
    taste_title VARCHAR(255) DEFAULT '취향 탐색 중', -- 
    taste_report TEXT,
    taste_anomaly_score DECIMAL(10, 5) DEFAULT 0.0
);



INSERT INTO member (id, password, role) VALUES ('admin', '1234', 'ADMIN');
INSERT INTO member (id, password, role) VALUES ('member1', '1234', 'MEMBER');
INSERT INTO member (id, password, role) VALUES ('guest', '1234', 'MEMBER'); -- 테스트용 일반 회원 추가
INSERT INTO member (id, password, role) VALUES ('1', '1', 'MEMBER');
INSERT INTO member (id, password, role) VALUES ('2', '2', 'MEMBER');


-- 5. 영화 테이블
CREATE TABLE movies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    api_id VARCHAR(255) UNIQUE,
    title VARCHAR(255) NOT NULL,
    director VARCHAR(255),
    release_date DATE,
    year INT,
    genre VARCHAR(255),
    rating DECIMAL(3, 1) DEFAULT 0.0,
    violence_score_avg DECIMAL(3, 1) DEFAULT 0.0,
    overview TEXT,
    poster_path VARCHAR(255),
    like_count INT DEFAULT 0,
    runtime VARCHAR(50),   
    rated VARCHAR(50),     
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6. 유저 리뷰 테이블
CREATE TABLE user_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    movie_id BIGINT NOT NULL,
    user_rating INT,
    violence_score INT,
    horror_score INT,   
    sexual_score INT,        
    review_content TEXT,
    tags VARCHAR(255) DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (member_id, movie_id),
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- 7. 유저 찜(User Cart) 테이블
CREATE TABLE user_carts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    movie_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (member_id, movie_id),   
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- 8. 관리자 추천 배너 테이블
CREATE TABLE admin_banner_movies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (movie_id), -- 한 영화는 배너에 한 번만 등록 가능
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- 9. 영화별 추가 통계 테이블 
CREATE TABLE movie_stats (
    movie_id BIGINT PRIMARY KEY,  -- FK → movies.id
    horror_score_avg DECIMAL(3,1) DEFAULT 0.0,
    sexual_score_avg DECIMAL(3,1) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- 10. 배우 테이블 (25.07.28 오후 추가)
CREATE TABLE actors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    tmdb_id INT, -- 유니크 제거 
    profile_image_url VARCHAR(255),
    birthday DATE,
    deathday DATE,
    age INT,
    place_of_birth VARCHAR(255),
    biography TEXT,
    gender TINYINT,
    known_for_department VARCHAR(50)
);

-- 11. 영화-배우/감독 연결 테이블 (25.07.28 오후 추가)
CREATE TABLE movie_actors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT NOT NULL,
    actor_id BIGINT NOT NULL,
    role_name VARCHAR(100),
    role_type VARCHAR(50) DEFAULT 'ACTOR', -- '배우', '감독'
    display_order INT DEFAULT 0,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE
);

-- 12. 영화-장르 매핑 테이블 (25.07.28 coco030)
CREATE TABLE movie_genres (
    movie_id BIGINT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    PRIMARY KEY (movie_id, genre), --  중복 조합 방지
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

--  영화별 이미지 테이블 (갤러리용)
CREATE TABLE movie_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,           -- 각 이미지 고유 ID
    movie_id BIGINT NOT NULL,                       -- 어떤 영화의 이미지인지 (FK)
    image_url VARCHAR(500) NOT NULL,                -- TMDb에서 받은 이미지 경로
    type VARCHAR(50) DEFAULT 'backdrop',            -- 이미지 종류 (예: backdrop, poster, logo)
    sort_order INT DEFAULT 0,                       -- 정렬 순서
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 저장 시각
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);


-- 주의 요소 마스터 테이블 (UNIQUE 제약조건 포함)
CREATE TABLE warning_tags (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    sentence VARCHAR(255) NOT NULL UNIQUE, -- 컬럼 정의 시 바로 UNIQUE를 명시
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 영화-주의 요소 매핑 테이블
-- movies와 warning_tags 테이블이 먼저 존재해야 생성 가능.
CREATE TABLE movie_warning_tags (
    movie_id BIGINT NOT NULL,
    warning_tag_id BIGINT NOT NULL,
    PRIMARY KEY (movie_id, warning_tag_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (warning_tag_id) REFERENCES warning_tags(id) ON DELETE CASCADE
);




--  데이터 확인용 SELECT (생성 순서와 일치)
SELECT * FROM member;
SELECT * FROM movies;
SELECT * FROM user_reviews;
SELECT * FROM user_carts;
SELECT * FROM admin_banner_movies;
SELECT * FROM movie_stats;      
SELECT * FROM actors;         
SELECT * FROM movie_actors;     
SELECT * FROM movie_genres;    
SELECT * FROM movie_images;
SELECT * FROM warning_tags;       
SELECT * FROM movie_warning_tags;


-- 배우들 정보 삭제 (순서대로.)
TRUNCATE TABLE movie_actors;
DELETE FROM actors;


-- ### **⭐ `like_count` 자동 업데이트를 위한 트리거 추가 ⭐**
DELIMITER //

CREATE TRIGGER trg_increase_like_count
AFTER INSERT ON user_carts
FOR EACH ROW
BEGIN
    UPDATE movies
    SET like_count = like_count + 1
    WHERE id = NEW.movie_id;
END;
//


-- user_carts에서 찜이 삭제될 때 like_count 감소
CREATE TRIGGER trg_decrease_like_count
AFTER DELETE ON user_carts
FOR EACH ROW
BEGIN
    UPDATE movies
    SET like_count = like_count - 1
    WHERE id = OLD.movie_id;
END;
//

DELIMITER ;



INSERT INTO warning_tags (category, sentence, sort_order) VALUES
-- 카테고리: 공포
('공포', '갑작스럽게 놀라게 하는 장면(점프 스케어)이 있어요.', 10),
('공포', '지속적인 긴장감이나 불안감을 유발해요.', 20),
('공포', '기괴하거나 초자연적인 존재가 등장해요.', 30),
('공포', '음향 효과로 공포감이나 불쾌감을 줘요.', 40),

-- 카테고리: 잔인성
('잔인성', '선혈이 낭자하거나 유혈 장면이 반복돼요.', 10),
('잔인성', '신체 절단이나 장기 훼손이 구체적으로 묘사돼요.', 20),
('잔인성', '훼손된 시체가 상세하게 등장해요.', 30),
('잔인성', '혐오감을 주는 벌레나 오물이 클로즈업돼요.', 40),

-- 카테고리: 폭력성
('폭력성', '구타, 집단 폭행 등 물리적 폭력이 자주 나와요.', 10),
('폭력성', '고문, 학대 등 과정이 상세하게 묘사돼요.', 20),
('폭력성', '총, 칼 등 무기를 사용한 폭력/살상 장면이 직접적으로 나와요.', 30),
('폭력성', '아동 학대나 가정 내 폭력 장면이 포함돼요.', 40),

-- 카테고리: 선정성
('선정성', '직접적인 성적 행위나 강한 암시가 있어요.', 10),
('선정성', '과도한 신체 노출 장면이 포함돼요.', 20),
('선정성', '성적인 폭력이나 강압적인 상황이 묘사/암시돼요.', 30),
('선정성', '성적 대상화나 불쾌감을 주는 대사가 있어요.', 40),

-- 카테고리: 기타
('기타', '자살 또는 자해 시도가 직접적으로 묘사돼요.', 10),
('기타', '욕설이나 비속어가 반복적으로 사용돼요.', 20),

-- 카테고리: 약물
('약물', '약물 사용이나 중독 관련 상황이 표현돼요.', 10),

-- 카테고리: 동물
('동물', '동물이 위험에 처하거나 고통받는 장면이 나와요.', 10),
('동물', '동물이 죽거나 죽음을 암시하는 장면이 있어요.', 20),
('동물', '동물의 사체가 화면에 직접 등장해요.', 30),
('동물', '동물이 실험, 사냥, 투견 등의 설정에 이용돼요.', 40);




-- 더미 데이터 
-- 배우 데이터 전체 (134명)
INSERT INTO `actors` VALUES (1,'Elijah Wood',109,'/7UKRbJBNG7mxBl2QQc5XsAh6F8B.jpg','1981-01-28',NULL,44,'Cedar Rapids, Iowa, USA','Elijah Jordan Wood (born January 28, 1981) is an American actor and producer. He rose to international fame for his portrayal of Frodo Baggins in The Lord of the Rings film trilogy (2001–2003) and The Hobbit: An Unexpected Journey (2012).\n\nWood made his film debut with a small part in Back to the Future Part II (1989). He went on to achieve recognition as a child actor with multiple roles such as Avalon (1990) and The Good Son (1993). As a teenager, he starred in several films including North (1994), Flipper (1996), and The Ice Storm (1997). Following the success of The Lord of the Rings, Wood has appeared in a wide range of films, including Eternal Sunshine of the Spotless Mind (2004), Paris, je t\'aime (2006), and I Don\'t Feel at Home in This World Anymore (2017).\n\nWood\'s voice roles include Mumble in the Happy Feet film franchise (2006–2011), the title protagonist in 9 (2009), Spyro the Dragon in the Legend of Spyro video game trilogy (2006–2008), Beck on Disney XD\'s Tron: Uprising (2012–2013), Sigma in Season 10 of Red vs. Blue, and Wirt in the Cartoon Network miniseries Over the Garden Wall (2014). He played Ryan Newman on the FX dark comedy series Wilfred (2011–2014), for which he received a Satellite Award nomination for Best Actor, and Todd Brotzman in the BBC America series Dirk Gently\'s Holistic Detective Agency (2016–2017).',2,'Acting'),(2,'Ian McKellen',1327,'/5cnnnpnJG6TiYUSS7qgJheUZgnv.jpg','1939-05-25',NULL,86,'Burnley, Lancashire, England, UK','Sir Ian Murray McKellen (born 25 May 1939) is an English actor. He has played roles on the screen and stage in genres ranging from Shakespearean dramas and modern theatre to popular fantasy and science fiction. He is regarded as a British cultural icon and was knighted by Queen Elizabeth II in 1991. He has received numerous accolades, including a Tony Award, six Olivier Awards, and a Golden Globe Award, as well as nominations for two Academy Awards, five BAFTA Awards and five Emmy Awards.\n\nMcKellen made his stage debut in 1961 at the Belgrade Theatre as a member of its repertory company, and in 1965 made his first West End appearance. In 1969, he was invited to join the Prospect Theatre Company to play the lead parts in Shakespeare\'s Richard II and Marlowe\'s Edward II. In the 1970s, McKellen became a stalwart of the Royal Shakespeare Company and the National Theatre of Great Britain. He has earned five Olivier Awards for his roles in Pillars of the Community (1977), The Alchemist (1978), Bent (1979), Wild Honey (1984), and Richard III (1995). McKellen made his Broadway debut in The Promise (1965). He received the Tony Award for Best Actor in a Play for his role as Antonio Salieri in Amadeus (1980). He was further nominated for Ian McKellen: Acting Shakespeare (1984). He returned to Broadway in Wild Honey(1986), Dance of Death (1990), No Man\'s Land (2013), and Waiting for Godot (2013), the latter two being a joint production with Patrick Stewart.\n\nMcKellen achieved worldwide fame for his film roles, including the titular King in Richard III(1995), James Whale in Gods and Monsters (1998), Magneto in the X-Men films, Cogsworth in Beauty and the Beast (2017) and Gandalf in The Lord of the Rings (2001–2003) and The Hobbit (2012–2014) trilogies. Other notable film roles include A Touch of Love (1969), Plenty (1985), Six Degrees of Separation (1993), Restoration (1995), Flushed Away (2006), Mr. Holmes (2015), and The Good Liar (2019).\n\nMcKellen came out as gay in 1988, and has since championed LGBT social movements worldwide. He was awarded the Freedom of the City of London in October 2014. McKellen is a cofounder of Stonewall, an LGBT rights lobby group in the United Kingdom, named after the Stonewall riots. He is also patron of LGBT History Month, Pride London, Oxford Pride, GayGlos, LGBT Foundation and FFLAG.\n\nDescription above from the Wikipedia article Ian McKellen, licensed under CC-BY-SA, full list of contributors on Wikipedia.',2,'Acting'),(3,'Viggo Mortensen',110,'/vH5gVSpHAMhDaFWfh0Q7BG61O1y.jpg','1958-10-20',NULL,66,'Watertown, New York, USA','Viggo Peter Mortensen, Jr. (born October 20, 1958) is an American actor, writer, director, producer, musician, and multimedia artist. Born and raised in the state of New York to a Danish father and American mother, he also lived in Argentina during his childhood. He is the recipient of various accolades including a Screen Actors Guild Award and has been nominated for three Academy Awards, three BAFTA Awards, and four Golden Globe Awards.',2,'Acting'),(4,'Sean Astin',1328,'/ywH1VvdwqlcnuwUVr0pV0HUZJQA.jpg','1971-02-25',NULL,54,'Santa Monica, California, USA','Sean Astin (born February 25, 1971) is an American film actor, director, and producer better known for his film roles as Mikey Walsh in The Goonies, the title character of Rudy, and Samwise Gamgee in the Lord of the Rings trilogy. In television, he appeared as Lynn McGill in the fifth season of 24. He also provided the voice for the title character in Disney\'s Special Agent Oso.',2,'Acting'),(5,'Andy Serkis',1333,'/eNGqhebQ4cDssjVeNFrKtUvweV5.jpg','1964-04-20',NULL,61,'Ruislip, Middlesex, England, UK','Andrew Clement Serkis (born 20 April 1964) is an English actor and filmmaker. He is best known for his motion capture roles comprising motion capture acting, animation and voice work for computer-generated characters such as Gollum in The Lord of the Rings film trilogy (2001–2003) and The Hobbit: An Unexpected Journey (2012), King Kong in the eponymous 2005 film, Caesar in the Planet of the Apes reboot series (2011–2017), Captain Haddock / Sir Francis Haddock in Steven Spielberg\'s The Adventures of Tintin (2011), Baloo in his self-directed film Mowgli: Legend of the Jungle (2018) and Supreme Leader Snoke in the Star Wars sequel trilogy films The Force Awakens (2015) and The Last Jedi (2017), also portraying Kino Loy in the Star Wars Disney+ series Andor (2022).\n\nSerkis\'s film work in motion capture has been critically acclaimed. He has received an Empire Award and two Saturn Awards for his motion-capture acting. He earned a BAFTA and a Golden Globe nomination for portraying serial killer Ian Brady in the British television film Longford (2006). He was nominated for a BAFTA for his portrayal of new wave and punk rock musician Ian Dury in the biopic Sex &amp; Drugs &amp; Rock &amp; Roll (2010). In 2020, Serkis received the BAFTA Award for Outstanding British Contribution To Cinema. In 2021, he won a Daytime Emmy Award for the series The Letter for the King (2020).\n\nSerkis portrayed Ulysses Klaue in the Marvel Cinematic Universe (MCU) films Avengers: Age of Ultron (2015) and Black Panther (2018), as well as the Disney+series What If…? (2021). He also played Alfred Pennyworth in The Batman (2022). Serkis has his own production company and motion capture workshop, The Imaginarium in London, which he used for Mowgli: Legend of the Jungle. He made his directorial debut with Imaginarium\'s 2017 film Breathe and directed Venom: Let There Be Carnage (2021).\n\nDescription above from the Wikipedia article Andy Serkis, licensed under CC-BY-SA, full list of contributors on Wikipedia.',2,'Acting');

-- 영화 데이터 전체
INSERT INTO `movies` VALUES (1,'tt0167260','The Lord of the Rings: The Return of the King','Peter Jackson','2003-12-17',2003,'Adventure, Drama, Fantasy',0.0,0.0,'Gandalf and Aragorn lead the World of Men against Sauron\'s army to draw his gaze from Frodo and Sam as they approach Mount Doom with the One Ring.','https://m.media-amazon.com/images/M/MV5BMTZkMjBjNWMtZGI5OC00MGU0LTk4ZTItODg2NWM3NTVmNWQ4XkEyXkFqcGc@._V1_SX300.jpg',0,'201 min','PG-13','2025-08-13 02:48:52','2025-08-13 02:48:52'),(2,'tt0110357','The Lion King','Roger Allers, Rob Minkoff','1994-06-24',1994,'Animation, Adventure, Drama',0.0,0.0,'Lion prince Simba and his father are targeted by his bitter uncle, who wants to ascend the throne himself.','https://m.media-amazon.com/images/M/MV5BZGRiZDZhZjItM2M3ZC00Y2IyLTk3Y2MtMWY5YjliNDFkZTJlXkEyXkFqcGc@._V1_SX300.jpg',0,'88 min','G','2025-08-13 02:48:59','2025-08-13 02:48:59'),(3,'tt6105098','The Lion King','Jon Favreau','2019-07-19',2019,'Animation, Adventure, Drama',0.0,0.0,'After the murder of his father, a young lion prince flees his kingdom only to learn the true meaning of responsibility and bravery.','https://m.media-amazon.com/images/M/MV5BMjIwMjE1Nzc4NV5BMl5BanBnXkFtZTgwNDg4OTA1NzM@._V1_SX300.jpg',0,'118 min','PG','2025-08-13 02:49:07','2025-08-13 02:49:07'),(4,'tt0349683','King Arthur','Antoine Fuqua','2004-07-07',2004,'Action, Adventure, Drama',0.0,0.0,'A demystified take on the tale of King Arthur and the Knights of the Round Table.','https://m.media-amazon.com/images/M/MV5BMTk4MTk1NjI0OV5BMl5BanBnXkFtZTcwNDQxOTUyMQ@@._V1_SX300.jpg',0,'126 min','PG-13','2025-08-13 02:49:15','2025-08-13 02:49:15'),(5,'tt2294629','Frozen','Chris Buck, Jennifer Lee','2013-11-27',2013,'Animation, Adventure, Comedy',8.0,1.0,'Fearless optimist Anna teams up with rugged mountain man Kristoff and his loyal reindeer Sven in an epic journey to find Anna\'s sister Elsa, whose icy powers have trapped the kingdom of Arendelle in eternal winter.','https://m.media-amazon.com/images/M/MV5BMTQ1MjQwMTE5OF5BMl5BanBnXkFtZTgwNjk3MTcyMDE@._V1_SX300.jpg',0,'102 min','PG','2025-08-13 02:49:45','2025-08-13 02:53:39'),(6,'tt4520988','Frozen II','Chris Buck, Jennifer Lee','2019-11-22',2019,'Animation, Adventure, Comedy',0.0,0.0,'Anna, Elsa, Kristoff, Olaf and Sven leave Arendelle to travel to an ancient, autumn-bound forest of an enchanted land. They set out to find the origin of Elsa\'s powers in order to save their kingdom.','https://m.media-amazon.com/images/M/MV5BZTE1YjlmZjctNjIwNi00NDQ0LTlmMzgtYWZkY2RkZTMwNTdmXkEyXkFqcGc@._V1_SX300.jpg',0,'103 min','PG','2025-08-13 02:49:52','2025-08-13 02:49:52'),(7,'tt0944835','Salt','Phillip Noyce','2010-07-23',2010,'Action, Thriller',7.0,1.0,'A CIA agent goes on the run after a defector accuses her of being a Russian spy.','https://m.media-amazon.com/images/M/MV5BMjIyODA2NDg4NV5BMl5BanBnXkFtZTcwMjg4NDAwMw@@._V1_SX300.jpg',0,'100 min','PG-13','2025-08-13 02:50:05','2025-08-13 02:53:12'),(8,'tt1229238','Mission: Impossible - Ghost Protocol','Brad Bird','2011-12-21',2011,'Action, Adventure, Thriller',0.0,0.0,'The IMF is shut down when it\'s implicated in the bombing of the Kremlin, causing Ethan Hunt and his new team to go rogue to clear their organization\'s name.','https://m.media-amazon.com/images/M/MV5BMTY4MTUxMjQ5OV5BMl5BanBnXkFtZTcwNTUyMzg5Ng@@._V1_SX300.jpg',0,'132 min','PG-13','2025-08-13 02:50:25','2025-08-13 02:50:25'),(9,'tt1219827','Ghost in the Shell','Rupert Sanders','2017-03-31',2017,'Action, Crime, Drama',4.0,1.0,'In the near future, Major Mira Killian is the first of her kind: A human saved from a terrible crash, who is cyber-enhanced to be a perfect soldier devoted to stopping the world\'s most dangerous criminals.','https://m.media-amazon.com/images/M/MV5BNzBkNjdjZTctNjdhOS00NmIyLTlkNjQtY2EwNGMwYmZjNTIxXkEyXkFqcGc@._V1_SX300.jpg',0,'107 min','PG-13','2025-08-13 02:50:31','2025-08-13 02:52:52'),(10,'tt12361974','Zack Snyder\'s Justice League','Zack Snyder','2021-03-18',2021,'Action, Adventure, Fantasy',0.0,0.0,'Determined to ensure that Superman\'s ultimate sacrifice wasn\'t in vain, Bruce Wayne recruits a team of metahumans to protect the world from an approaching threat of catastrophic proportions.','https://m.media-amazon.com/images/M/MV5BNDA0MzM5YTctZTU2My00NGQ5LWE2NTEtNDM0MjZmMDBkOTZkXkEyXkFqcGc@._V1_SX300.jpg',0,'242 min','R','2025-08-13 02:50:56','2025-08-13 02:50:56'),(11,'tt0816711','World War Z','Marc Forster','2013-06-21',2013,'Action, Adventure, Horror',6.0,2.0,'Former United Nations employee Gerry Lane traverses the world in a race against time to stop a zombie pandemic that is toppling armies and governments and threatens to destroy humanity itself.','https://m.media-amazon.com/images/M/MV5BODg3ZTM2YWQtZDE5Ny00NGNiLTkzYjgtYWVlYjNkOTg5NDI1XkEyXkFqcGc@._V1_SX300.jpg',0,'116 min','PG-13','2025-08-13 02:51:15','2025-08-13 02:52:29'),(12,'tt1981115','Thor: The Dark World','Alan Taylor','2013-11-08',2013,'Action, Adventure, Fantasy',0.0,0.0,'When the Dark Elves attempt to plunge the universe into darkness, Thor must embark on a perilous and personal journey that will reunite him with doctor Jane Foster.','https://m.media-amazon.com/images/M/MV5BMTQyNzAwOTUxOF5BMl5BanBnXkFtZTcwMTE0OTc5OQ@@._V1_SX300.jpg',0,'112 min','PG-13','2025-08-13 02:51:22','2025-08-13 02:51:22');

-- 회원 데이터
INSERT INTO `member` VALUES ('1','1','ACTIVE','MEMBER','취향 탐색 중...','아직 평가가 부족해요. 5편 이상의 영화를 평가하면 당신만의 취향 리포트가 생성됩니다.',0.00000),('2','2','ACTIVE','MEMBER','취향 탐색 중',NULL,0.00000),('admin','1234','ACTIVE','ADMIN','취향 탐색 중',NULL,0.00000),('guest','1234','ACTIVE','MEMBER','취향 탐색 중',NULL,0.00000),('member1','1234','ACTIVE','MEMBER','취향 탐색 중',NULL,0.00000);

-- 배너 영화
INSERT INTO `admin_banner_movies` VALUES (1,12,0,'2025-08-13 02:51:39'),(2,8,0,'2025-08-13 02:51:41'),(3,5,0,'2025-08-13 02:51:42'),(4,4,0,'2025-08-13 02:51:44');

-- 영화-배우 관계 (144개 전체)
INSERT INTO `movie_actors` VALUES (1,1,1,'Frodo','ACTOR',0),(2,1,2,'Gandalf','ACTOR',1),(3,1,3,'Aragorn','ACTOR',2),(4,1,4,'Sam','ACTOR',3),(5,1,5,'Gollum / Smeagol','ACTOR',4),(6,1,6,'Merry','ACTOR',5),(7,1,7,'Pippin','ACTOR',6),(8,1,8,'Denethor','ACTOR',7),(9,1,9,'Faramir','ACTOR',8),(10,1,10,'Éowyn','ACTOR',9),(11,1,11,'Théoden','ACTOR',10),(12,1,12,'감독','DIRECTOR',11),(13,2,13,'Simba (voice)','ACTOR',0),(14,2,14,'Nala (voice)','ACTOR',1),(15,2,15,'Timon (voice)','ACTOR',2),(16,2,16,'Pumbaa (voice)','ACTOR',3),(17,2,17,'Mufasa (voice)','ACTOR',4),(18,2,18,'Scar (voice)','ACTOR',5),(19,2,19,'Rafiki (voice)','ACTOR',6),(20,2,20,'Zazu (voice)','ACTOR',7),(21,2,21,'Young Simba (voice)','ACTOR',8),(22,2,22,'Young Nala (voice)','ACTOR',9),(23,2,23,'Shenzi (voice)','ACTOR',10),(24,2,24,'감독','DIRECTOR',11),(25,3,25,'Scar (voice)','ACTOR',0),(26,3,26,'Zazu (voice)','ACTOR',1),(27,3,27,'Simba (voice)','ACTOR',2),(28,3,17,'Mufasa (voice)','ACTOR',3),(29,3,28,'Rafiki (voice)','ACTOR',4),(30,3,29,'Sarabi (voice)','ACTOR',5),(31,3,30,'Nala (voice)','ACTOR',6),(32,3,31,'Young Simba (voice)','ACTOR',7),(33,3,32,'Young Nala (voice)','ACTOR',8),(34,3,33,'Sarafina (voice)','ACTOR',9),(35,3,34,'Kamari (voice)','ACTOR',10),(36,3,35,'감독','DIRECTOR',11),(37,4,36,'Arthur','ACTOR',0),(38,4,37,'Lancelot','ACTOR',1),(39,4,38,'Guinevere','ACTOR',2),(40,4,39,'Tristan','ACTOR',3),(41,4,40,'Gawain','ACTOR',4),(42,4,41,'Galahad','ACTOR',5),(43,4,42,'Bors','ACTOR',6),(44,4,43,'Merlin','ACTOR',7),(45,4,44,'Dagonet','ACTOR',8),(46,4,45,'Cynric','ACTOR',9),(47,4,46,'Cerdic','ACTOR',10),(48,4,47,'감독','DIRECTOR',11),(49,5,48,'Elsa (voice)','ACTOR',0),(50,5,49,'Anna (voice)','ACTOR',1),(51,5,50,'Kristoff (voice)','ACTOR',2),(52,5,51,'Olaf (voice)','ACTOR',3),(53,5,52,'Young Anna (voice)','ACTOR',4),(54,5,53,'Hans (voice)','ACTOR',5),(55,5,54,'Young Elsa (voice)','ACTOR',6),(56,5,55,'Duke (voice)','ACTOR',7),(57,5,56,'Bulda (voice)','ACTOR',8),(58,5,57,'Pabbie / Grandpa (voice)','ACTOR',9),(59,5,58,'Baby Troll (voice)','ACTOR',10),(60,5,59,'감독','DIRECTOR',11),(61,6,48,'Elsa (voice)','ACTOR',0),(62,6,49,'Anna (voice)','ACTOR',1),(63,6,51,'Olaf (voice)','ACTOR',2),(64,6,50,'Kristoff / Sven / Reindeers (voice)','ACTOR',3),(65,6,60,'Iduna (voice)','ACTOR',4),(66,6,61,'Mattias (voice)','ACTOR',5),(67,6,62,'Agnarr (voice)','ACTOR',6),(68,6,63,'Honeymaren (voice)','ACTOR',7),(69,6,64,'Ryder (voice)','ACTOR',8),(70,6,65,'Yelena (voice)','ACTOR',9),(71,6,57,'Pabbie (voice)','ACTOR',10),(72,6,66,'감독','DIRECTOR',11),(73,7,67,'Evelyn Salt','ACTOR',0),(74,7,68,'Theodore Winter','ACTOR',1),(75,7,25,'Darryl Peabody','ACTOR',2),(76,7,69,'Oleg Vasilyevich Orlov','ACTOR',3),(77,7,70,'Mike Krause','ACTOR',4),(78,7,71,'Young Orlov','ACTOR',5),(79,7,72,'US President Howard Lewis','ACTOR',6),(80,7,73,'Secretary of Defense','ACTOR',7),(81,7,74,'Russian President Matveyev','ACTOR',8),(82,7,75,'Young Salt','ACTOR',9),(83,7,76,'Shnaider','ACTOR',10),(84,7,77,'감독','DIRECTOR',11),(85,8,78,'Ethan Hunt','ACTOR',0),(86,8,79,'Jane','ACTOR',1),(87,8,80,'Benji','ACTOR',2),(88,8,81,'Brandt','ACTOR',3),(89,8,82,'Hendricks','ACTOR',4),(90,8,83,'Sidorov','ACTOR',5),(91,8,84,'Wistrom','ACTOR',6),(92,8,85,'Leonid Lisenker','ACTOR',7),(93,8,86,'Brij Nath','ACTOR',8),(94,8,87,'Sabine Moreau','ACTOR',9),(95,8,88,'Hanaway','ACTOR',10),(96,8,89,'감독','DIRECTOR',11),(97,9,90,'Major','ACTOR',0),(98,9,91,'Aramaki','ACTOR',1),(99,9,92,'Kuze','ACTOR',2),(100,9,93,'Batou','ACTOR',3),(101,9,94,'Togusa','ACTOR',4),(102,9,95,'Dr. Ouelet','ACTOR',5),(103,9,96,'Cutter','ACTOR',6),(104,9,97,'Red Robed Geisha','ACTOR',7),(105,9,98,'Skinny Man','ACTOR',8),(106,9,99,'Saito','ACTOR',9),(107,9,100,'Dr. Dahlin','ACTOR',10),(108,9,101,'감독','DIRECTOR',11),(109,10,102,'Batman / Bruce Wayne','ACTOR',0),(110,10,103,'Superman / Clark Kent','ACTOR',1),(111,10,104,'Wonder Woman / Diana Prince','ACTOR',2),(112,10,105,'Cyborg / Victor Stone','ACTOR',3),(113,10,106,'Aquaman / Arthur Curry','ACTOR',4),(114,10,107,'The Flash / Barry Allen','ACTOR',5),(115,10,57,'Steppenwolf (voice)','ACTOR',6),(116,10,108,'Lois Lane','ACTOR',7),(117,10,109,'Vulko','ACTOR',8),(118,10,18,'Alfred','ACTOR',9),(119,10,110,'Lex Luthor','ACTOR',10),(120,10,111,'감독','DIRECTOR',11),(121,11,112,'Gerry Lane','ACTOR',0),(122,11,113,'Karen Lane','ACTOR',1),(123,11,114,'Segen','ACTOR',2),(124,11,115,'Captain Speke','ACTOR',3),(125,11,116,'Jurgen Warmbrunn','ACTOR',4),(126,11,117,'Parajumper','ACTOR',5),(127,11,118,'Thierry Umutoni','ACTOR',6),(128,11,119,'Ex-CIA Agent','ACTOR',7),(129,11,120,'Andrew Fassbach','ACTOR',8),(130,11,121,'Constance Lane','ACTOR',9),(131,11,122,'W.H.O. Doctor','ACTOR',10),(132,11,123,'감독','DIRECTOR',11),(133,12,124,'Thor','ACTOR',0),(134,12,125,'Jane Foster','ACTOR',1),(135,12,126,'Loki','ACTOR',2),(136,12,127,'Malekith','ACTOR',3),(137,12,128,'Odin','ACTOR',4),(138,12,129,'Sif','ACTOR',5),(139,12,130,'Fandral','ACTOR',6),(140,12,44,'Volstagg','ACTOR',7),(141,12,131,'Hogun','ACTOR',8),(142,12,132,'Heimdall','ACTOR',9),(143,12,133,'Frigga','ACTOR',10),(144,12,134,'감독','DIRECTOR',11);

-- 영화-장르 관계
INSERT INTO `movie_genres` VALUES (1,'Adventure'),(1,'Drama'),(1,'Fantasy'),(2,'Adventure'),(2,'Animation'),(2,'Drama'),(3,'Adventure'),(3,'Animation'),(3,'Drama'),(4,'Action'),(4,'Adventure'),(4,'Drama'),(5,'Adventure'),(5,'Animation'),(5,'Comedy'),(6,'Adventure'),(6,'Animation'),(6,'Comedy'),(7,'Action'),(7,'Thriller'),(8,'Action'),(8,'Adventure'),(8,'Thriller'),(9,'Action'),(9,'Crime'),(9,'Drama'),(10,'Action'),(10,'Adventure'),(10,'Fantasy'),(11,'Action'),(11,'Adventure'),(11,'Horror'),(12,'Action'),(12,'Adventure'),(12,'Fantasy');

-- 영화 통계
INSERT INTO `movie_stats` VALUES (5,1.0,1.0,0,'2025-08-13 02:53:40'),(7,1.0,1.0,0,'2025-08-13 02:53:13'),(9,1.0,1.0,0,'2025-08-13 02:52:54'),(11,2.0,1.0,0,'2025-08-13 02:52:30');

-- 영화-경고태그 관계
INSERT INTO `movie_warning_tags` VALUES (11,1),(11,5);

-- 사용자 카트
INSERT INTO `user_carts` VALUES (1,'1',12,'2025-08-13 02:53:24'),(2,'1',8,'2025-08-13 02:53:31');

-- 사용자 리뷰
INSERT INTO `user_reviews` VALUES (1,'1',11,6,2,2,1,'1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음. 1000자를 위핸 리뷰. 더보기 기능이 있음.','','2025-08-13 02:52:27'),(6,'1',9,4,1,1,1,'영화관에서 봤는데 시간낭비였음','','2025-08-13 02:52:50'),(12,'1',7,7,1,1,1,'여주 남편이 안타까움','','2025-08-13 02:53:11'),(17,'1',5,8,1,1,1,'ㅇㅇ','','2025-08-13 02:53:38');
