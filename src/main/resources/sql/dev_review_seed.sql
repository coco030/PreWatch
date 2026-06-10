USE prewatch_db;

INSERT INTO user_reviews
    (member_id, movie_id, user_rating, violence_score, horror_score, sexual_score, review_content, tags, created_at)
VALUES
    ('1', 6, 10, 1, 1, 1, '음악과 화면이 편해서 다시 틀어두고 싶은 영화였어요. 가족 영화로 추천하기 좋아요.', '가족,음악,재관람', NOW() - INTERVAL 8 HOUR),
    ('1', 9, 7, 1, 1, 1, '가볍게 보기 좋고 동물 캐릭터가 귀여웠어요. 큰 자극 없이 볼 수 있었어요.', '가족,동물,가벼움', NOW() - INTERVAL 16 HOUR),
    ('1', 12, 9, 3, 2, 1, '생존 이야기가 무겁지 않게 흘러가서 좋았고, 과학 소재도 부담 없이 볼 수 있었어요.', 'SF,생존,몰입', NOW() - INTERVAL 24 HOUR),
    ('1', 13, 9, 5, 3, 2, '시간을 오가는 설정이 흥미로웠고 액션도 과하지 않게 느껴졌어요.', '액션,SF,히어로', NOW() - INTERVAL 30 HOUR),
    ('2', 14, 10, 6, 4, 2, '긴 러닝타임인데도 장면마다 힘이 있어서 끝까지 몰입했어요. 판타지 대작 느낌이 확실해요.', '판타지,대서사,전투', NOW() - INTERVAL 3 HOUR),
    ('2', 11, 8, 6, 4, 3, '추격 장면이 빠르게 이어져서 지루하지 않았어요. 스릴러 좋아하면 무난히 볼 만해요.', '스릴러,추격,액션', NOW() - INTERVAL 11 HOUR),
    ('2', 8, 8, 7, 4, 3, '액션은 강한 편이지만 분위기가 세련돼서 계속 보게 됐어요.', '액션,스파이,긴장감', NOW() - INTERVAL 19 HOUR),
    ('2', 1, 8, 8, 4, 4, '잔인한 장면이 조금 부담스러울 수 있지만 특유의 유머와 속도감은 좋았어요.', '액션,코미디,성인취향', NOW() - INTERVAL 27 HOUR),
    ('3', 4, 8, 1, 1, 1, '전편보다 이야기가 조금 복잡하지만 노래와 화면은 여전히 예뻤어요.', '애니메이션,가족,음악', NOW() - INTERVAL 5 HOUR),
    ('3', 5, 7, 1, 1, 1, '캐릭터를 좋아한다면 기대하게 되는 작품이에요. 편하게 볼 수 있는 분위기가 좋아요.', '애니메이션,가족,판타지', NOW() - INTERVAL 13 HOUR),
    ('3', 7, 7, 2, 1, 1, '어린 시절 생각나게 하는 장면이 많았고, 부담 없이 보기 좋았어요.', '가족,모험,동물', NOW() - INTERVAL 21 HOUR),
    ('3', 10, 9, 2, 2, 1, '상상력을 자극하는 설정이 좋아요. 개봉하면 가장 먼저 확인하고 싶은 영화예요.', 'SF,우주,기대작', NOW() - INTERVAL 29 HOUR),
    ('4', 2, 9, 6, 3, 2, '히어로가 모이는 장면만으로도 충분히 즐거웠고, 전투 장면도 시원했어요.', '히어로,액션,팀업', NOW() - INTERVAL 7 HOUR),
    ('4', 3, 8, 6, 4, 2, '아직 기대작에 가깝지만 세계관이 이어지는 느낌이 좋아서 궁금해요.', '히어로,SF,기대작', NOW() - INTERVAL 15 HOUR),
    ('4', 13, 10, 5, 3, 2, '캐릭터가 많아도 이야기가 잘 정리되어 있어서 다시 봐도 재미있었어요.', '히어로,SF,시간여행', NOW() - INTERVAL 4 HOUR),
    ('4', 12, 8, 3, 2, 1, '절망적인 상황인데도 유머가 살아 있어서 보기 편했어요.', 'SF,생존,유머', NOW() - INTERVAL 23 HOUR),
    ('5', 15, 7, 3, 5, 2, '소재가 불안감을 주는 편이라 편한 영화는 아니었지만 긴장감은 잘 살아 있었어요.', '드라마,스릴러,불안감', NOW() - INTERVAL 2 HOUR),
    ('5', 11, 7, 6, 5, 3, '액션보다 의심과 추격의 흐름이 더 기억에 남았어요.', '스릴러,첩보,긴장감', NOW() - INTERVAL 10 HOUR),
    ('5', 8, 8, 7, 4, 3, '전쟁과 스파이 분위기가 섞여서 기존 시리즈와 다른 맛이 있었어요.', '스파이,전쟁,액션', NOW() - INTERVAL 18 HOUR),
    ('5', 14, 9, 6, 5, 2, '전투 장면은 강하지만 감정선이 좋아서 오래 남는 영화였어요.', '판타지,전투,감동', NOW() - INTERVAL 26 HOUR),
    ('6', 6, 9, 1, 1, 1, '캐릭터 감정선이 선명해서 다시 봐도 마음이 편해졌어요.', '가족,음악,힐링', NOW() - INTERVAL 6 HOUR),
    ('6', 4, 9, 1, 1, 1, '노래가 좋아서 장면보다 음악이 먼저 떠오르는 영화였어요.', '애니메이션,음악,자매', NOW() - INTERVAL 14 HOUR),
    ('6', 9, 8, 1, 1, 1, '강아지들이 화면을 채우는 것만으로도 즐겁고 귀여웠어요.', '가족,동물,코미디', NOW() - INTERVAL 22 HOUR),
    ('6', 7, 8, 2, 1, 1, '모험 분위기가 밝아서 아이와 같이 봐도 무난할 것 같아요.', '가족,모험,동물', NOW() - INTERVAL 28 HOUR),
    ('7', 1, 7, 8, 4, 4, '스타일은 멋지지만 폭력 묘사가 꽤 강해서 취향을 탈 것 같아요.', '액션,폭력성,코미디', NOW() - INTERVAL 9 HOUR),
    ('7', 2, 9, 6, 3, 2, '캐릭터 조합이 좋아서 가볍게 다시 보기 좋은 히어로 영화예요.', '히어로,액션,오락성', NOW() - INTERVAL 17 HOUR),
    ('7', 11, 8, 6, 4, 3, '전개가 빠르고 목적이 분명해서 킬링타임으로 좋았어요.', '첩보,액션,추격', NOW() - INTERVAL 25 HOUR),
    ('7', 12, 9, 3, 2, 1, '과학 설명보다 사람이 버티는 이야기가 더 크게 다가왔어요.', 'SF,생존,희망', NOW() - INTERVAL 12 HOUR),
    ('8', 10, 8, 2, 2, 1, '아직 기대작이지만 원작 분위기를 생각하면 밝은 SF 모험이 될 것 같아요.', 'SF,모험,기대작', NOW() - INTERVAL 1 HOUR),
    ('8', 15, 6, 3, 5, 2, '불안한 소재라 호불호가 있을 것 같지만 분위기는 확실했어요.', '드라마,스릴러,호불호', NOW() - INTERVAL 20 HOUR)
ON DUPLICATE KEY UPDATE
    user_rating = VALUES(user_rating),
    violence_score = VALUES(violence_score),
    horror_score = VALUES(horror_score),
    sexual_score = VALUES(sexual_score),
    review_content = VALUES(review_content),
    tags = VALUES(tags),
    created_at = VALUES(created_at);

UPDATE movies m
JOIN (
    SELECT
        movie_id,
        ROUND(AVG(user_rating), 1) AS rating_avg,
        ROUND(AVG(violence_score), 1) AS violence_avg
    FROM user_reviews
    GROUP BY movie_id
) r ON m.id = r.movie_id
SET
    m.rating = COALESCE(r.rating_avg, 0),
    m.violence_score_avg = COALESCE(r.violence_avg, 0);

INSERT INTO movie_stats (movie_id, horror_score_avg, sexual_score_avg, review_count)
SELECT
    m.id,
    COALESCE(ROUND(AVG(ur.horror_score), 1), 0),
    COALESCE(ROUND(AVG(ur.sexual_score), 1), 0),
    COUNT(ur.id)
FROM movies m
LEFT JOIN user_reviews ur ON m.id = ur.movie_id
GROUP BY m.id
ON DUPLICATE KEY UPDATE
    horror_score_avg = VALUES(horror_score_avg),
    sexual_score_avg = VALUES(sexual_score_avg),
    review_count = VALUES(review_count);
