-- 06-alter.sql

USE lecture;
DESC members;
SELECT * FROM members;

-- 테이블 스키마(컬럼 구조) 변경
ALTER TABLE members ADD COLUMN age INT NOT NULL DEFAULT 20;
-- NOT NULL 해놓으면, 알아서 0으로 박아줌. 근데 default 값을 안 잡았는데 자동으로 잡는 건 문제가 있음. 주의할 것.
-- 새로운 COLUMN 추가할 때, 기본값을 고려해야 함.
ALTER TABLE members DROP COLUMN age;
-- 컬럼 지우기.
ALTER TABLE members ADD COLUMN address VARCHAR(100) DEFAULT '미입력';

SELECT * FROM members;
-- 컬럼 이름 수정 
ALTER TABLE members CHANGE COLUMN address juso VARCHAR(100);
-- 컬럼 데이터 타입 수정A
ALTER TABLE members MODIFY COLUMN juso VARCHAR(2);
-- 이름 & 데이터 타입 수정
ALTER TABLE members CHANGE COLUMN juso goggi VARCHAR(77);