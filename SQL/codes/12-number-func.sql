# 12-number-func.sql

USE lecture;

# 실수 관련 함수들

SELECT
	name,
    score AS 원점수,
    ROUND(score) AS 반올림,
    ROUND(score, 1) AS 소수_1_반올림,
    CEIL(score) AS 올림,
    FLOOR(score) AS 내림,
    TRUNCATE(score, 1) AS 소수_1_버림 #내림과 버림의 차이는 음수에서 나ㅇ
FROM dt_demo;

# 사칙연산

SELECT
	10 + 5 AS plus,
    10 - 5 AS minus,
    10 * 5 AS multiply,
    10 / 5 AS devide,
    10 DIV 3 AS 몫,
    10 % 3 AS 나머지,
    MOD(10,3) AS 나머지2, # modulo 나머지
    POWER(10, 3) AS 거듭제곱, # power 거듭제곱 제곱, 세제곱은 따로 부르는 게 있음
    # ^2 Square ^3 Cube
    SQRT(16) AS 루트,
    ABS(-10) AS 절댓값;
    
SELECT * FROM dt_demo;

SELECT
	id, name,
    id % 2 AS 나머지,
    CASE
		WHEN id % 2 = 0
			THEN '짝수'
        ELSE '홀수'
	END AS 홀짝
FROM dt_demo;
    
# 조건문 IF, CASE
SELECT
	name,
    score,
    IF(	score >= 80, "우수", '보통') AS 평가  # IF는 이정도의 OX 판단밖에 못함.
FROM dt_demo;

SELECT
	name, --  컬럼 구분할 때만 ',' 쓰고
    IFNULL(score, 0) AS 점수,
    CASE
		WHEN score >= 90 THEN 'A'
        WHEN score >= 80 THEN 'b'
        WHEN score >= 70 THEN 'C'
        ELSE 'D'
	END AS 등급
FROM dt_demo;

INSERT INTO dt_demo(name) VALUES('이상한');
SELECT * FROM dt_demo;

