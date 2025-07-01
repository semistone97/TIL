-- p01.sql

-- 1. practice db 사용
-- 2. userinfo 테이블 생성
 	-- id PK, auto inc,int
	-- nickname: 20자 글자, 필수 입력
    -- phone 11 글잒자ㅣ, 중복방지
    -- reg_date 날짜, 기본값(오늘 날짜)
-- 3. desc로 테이블 정보 확인

USE practice;
CREATE TABLE userinfo(
	id INT AUTO_INCREMENT PRIMARY KEY, -- 순서는 바뀔 수 있음
    nickname VARCHAR(20) NOT NULL,
    phone VARCHAR(11) UNIQUE,
    reg_date DATE DEFAULT(CURRENT_DATE)
);

SHOW TABLES;

DESC userinfo;
    