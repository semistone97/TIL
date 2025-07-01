-- 02-create-table.sql

CREATE TABLE sample (
	name VARCHAR(30),
    age INT
);
-- 테이블 삭제
DROP TABLE sample;

SHOW TABLES;

CREATE TABLE members(
	id INT AUTO_INCREMENT PRIMARY KEY, -- 회원 고유번호(정수, 자동증가)
    name VARCHAR(30) NOT NULL, -- 이름인데 필수 입력을 해야 함
	email VARCHAR(100) UNIQUE, -- 이메일(중복 불가능)
    join_date DATE DEFAULT(CURRENT_DATE) -- 가입일(기본값-오늘)

);

SHOW TABLES;
-- DESC: describe
DESC members;
