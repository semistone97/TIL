# p07.sql

USE practice;
DROP TABLE at_demo2;
CREATE TABLE dt_demo2 AS SELECT * FROM lecture.dt_demo;
-- 종합 정보 표시
SELECT * FROM dt_demo2;

SELECT

-- id
	id,
-- name
	name,
-- 닉네임(NULL -> 미설정)
	IFNULL(nickname, '미설정') AS 닉네임,
-- 출생년도(19XX년생)
	YEAR(birth) AS 출생년도,
-- 나이 (TIMESTAMPDIFF로 나이만 표시)
	TIMESTAMPDIFF(YEAR, birth, CURDATE()) AS 나이,
-- 점수(소수1자리 반올림_ NULL -> 0)
	IFNULL(ROUND(score, 1),0) AS 점수,
    
    # IF(score IS NOT NULL, ROUND(score, 1), 0) AS 점수
    # COALESCE(ROUND(score, 1), 0) AS 점수
    
-- 등급, (A 90 B 80 C 70)
	CASE
		WHEN score >= 90 THEN 'A'
        WHEN score >= 80 THEN 'b'
        WHEN score >= 70 THEN 'C'
        ELSE 'D'
	END AS 등급,
-- 상태 (is_active 1이면 활성, 아니면 비활성)
	IF(is_active=TRUE, '활성', '비활성') AS 상태,
-- 연령대(청년 < 30 < 청장년 < 장년)
    CASE
        WHEN birth IS NULL THEN '미입력'
        WHEN TIMESTAMPDIFF(YEAR, birth, CURDATE()) < 30 THEN '청년'
        WHEN TIMESTAMPDIFF(YEAR, birth, CURDATE()) < 50 THEN '청장년'
        ELSE '장년'
	END AS 연령대
FROM dt_demo2;

DESC dt_demo2;
UPDATE dt_demo2 SET is_active = 0 WHERE birth IS NULL;