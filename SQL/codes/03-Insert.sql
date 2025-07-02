-- 03-insert.sql

USE lecture;
DESC members;

-- 데이터 입력
INSERT INTO members (name, email) VALUES ('오준석','jol@ryo.yo');
INSERT INTO members (name, email) VALUES ('강아지','ppo@mmi.kim');

 -- INSERT INTO가  한 세트
 
-- 여러 개 한 번에 하는 법
INSERT INTO members (name,email) VALUES 
('김기승','kim@ki.seung'),
('신현승','shin@hyun.seung');
 
-- 데이터 확인(전체 조회)
SELECT * FROM members; -- '*'의 뜻 -> 알아서 잘 => 모든 column을 다 가져오라는 뜻.
 
-- 데이터 단일 조회
SELECT * FROM members WHERE id=1;
