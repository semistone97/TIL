# datetime-func.sql

USE lecture;
SELECT * FROM dt_demo;

# 현재 날짜/시간
# 날짜 + 시간

SELECT NOW() AS '지금 시간';
SELECT CURRENT_TIMESTAMP;

# 날짜만 보는 법
SELECT CURDATE();
SELECT CURRENT_DATE;

# 시간만 보는 법
SELECT CURTIME();
SELECT CURRENT_TIME;

# 날짜 및 시간이 적용되는 방식 : YYYY-MM-DD
# 포맷 바꾸기

SELECT 
	name,
    birth AS 원본,
    DATE_FORMAT(birth, '%Y년 %m월 %d일') AS 한국식,
    DATE_FORMAT(birth, '%Y-%m') AS 년월,
    DATE_FORMAT(birth, '%M %d, %Y') AS 영문식,
    DATE_FORMAT(birth, '%w') AS '요일 번호',
    DATE_FORMAT(birth, '%W') AS '요일 이름',
    DATE_FORMAT(birth, '%Y %y %M %m %D %d %W %w') AS 전
FROM dt_demo;


SELECT
	created_at AS 원본시간,
    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i')AS 분까지만,
    DATE_FORMAT(created_at, '%p %h:%i') AS 12시간,
    DATE_FORMAT(created_at, '%a %s:%I') AS 이것저것
FROM dt_demo;

# 날짜 계산 함수
SELECT
	name,
    birth,
    DATEDIFF(CURDATE(),birth) AS 인생일수,
    TIMESTAMPDIFF(YEAR, birth, CURDATE()) AS 나이 # 처음 나온 게 결과 단위
    # DAY로 바꾸면 D-DAY 계산기
FROM dt_demo;


# 날짜 더하기 뺴기
SELECT
	name,
    birth,
    DATE_ADD(birth, INTERVAL 100 DAY) AS 백일후,
    DATE_ADD(birth, INTERVAL 1 YEAR) AS 돌,
    DATE_SUB(birth, INTERVAL 1 MONTH) AS 등장
FROM dt_demo;

# 계정 생성 후 경과 시간
SELECT 
	name, created_at,
    TIMESTAMPDIFF(HOUR, created_at, NOW()) AS '가입 후 시간', #이거는 웬만하면 띄어쓰기 하지 말고, 굳이 할 거면 _ 쓰세요.
    TIMESTAMPDIFF(DAY, created_at, NOW()) AS '가입 후 일수'
FROM dt_demo;

# 날짜 구성 요소 추출(구성요소?)_

SELECT
	name, # 컬럼마다 띄는 게 좋다고 하심
    birth, # birth는 DATE만 담고 있음
    YEAR(birth),
    MONTH(birth),
    DAY(birth),
    DAYOFWEEK(birth) AS 요일번호,
    QUARTER(birth) AS 분기,
    DAYNAME(birth) AS 요일이름 # 다만 char가 고정값이라, 번호를 바탕으로 그냥 설정하는 일이 잦
FROM dt_demo;

SELECT
	YEAR(birth) AS 출생년도,
	COUNT(*) AS 인원수
FROM dt_demo
GROUP BY YEAR(birth)
ORDER BY 출생년도;

