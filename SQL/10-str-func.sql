# 10-str-func.sql

USE lecture;

# 문자열 길이
SELECT LENGTH('hello SQL');
SELECT nickname , LENGTH(nickname) FROM dt_demo;
# LENGTH가 용량의 영향을 받기 때문에 길이를 보고 싶으면 LENGTH를 쓰면 안 됨.

SELECT name, CHAR_LENGTH(name) AS '이름 길이'  FROM dt_demo; # AS는 가상 컬럼 이름 정해주기
# 위 쿼리를 통해 알 수 있는 것 -> 없는 컬럼(가상 컬럼)을 통해서 뭔가를 알 수가 있구나.
# 가상 컬럼 이름 지어줄 떄는 웬만하면 str으로 쓰도록(아니면 띄어쓰기를 반영 못 함)


# 문자열 연결
SELECT CONCAT('hello', 'sql', '!!');
SELECT CONCAT(name, '(',score, ')')AS info FROM dt_demo;

# 대소문자
SELECT 
	nickname, 
	UPPER(nickname) AS UN,
    LOWER(nickname) AS LN
FROM dt_demo;


# 부분 문자열 추출(문자열, 시작점, 길이)
SELECT SUBSTRING('hello sql!',2,4);
SELECT LEFT('hello sql!', 5);
SELECT RIGHT('hello sql!', 5);
SELECT
    description,
    CONCAT(
		SUBSTRING(description, 1, 5),'...'
    ) AS intro,
    CONCAT(
		LEFT(description,5),
        '...',
        RIGHT(description, 3)
        ) AS summary
        
FROM dt_demo;
    
SELECT REPLACE('atest.com','test','gma');
SELECT 
	description,
    REPLACE(description, '학생', '**') AS secret
FROM dt_demo;

SELECT LOCATE('g',' googl e');