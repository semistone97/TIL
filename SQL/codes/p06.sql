-- p06.sql

USE practice;

SELECT * FROM userinfo;

-- 별명 길이 확인
SELECT name, CHAR_LENGTH(name) AS '별명 길이' FROM userinfo;

-- 별명 과 email 을 '-' 로 합쳐서 info (가상)컬럼으로 확인해 보기
SELECT CONCAT(name,'-',email) AS '합쳐' FROM userinfo;
-- 별명 은 모두 대문자로, email은 모두 소문자로 확인
SELECT name,
	UPPER(name)
FROM userinfo;
SELECT email,
	LOWER(email)
    FROM userinfo;

-- email 에서 gmail.com 을 naver.com 으로 모두 new_email 컬럼으로 추출
SELECT REPLACE(email, 'gmail.com','naver.com')
	AS new_email
    FROM userinfo;

-- email 앞에 붙은 단어만 username 컬럼 으로 확인 
SELECT SUBSTRING(email,1, LOCATE('@',email)-1) FROM userinfo;
-- (추가 과제 -> email 이 NULL 인 경우 'No Mail' 이라고 표시
SELECT REPLACE(email, NULL, "No Mail") FROM userinfo;
UPDATE userinfo SET email='No Mail' WHERE email=NULL;