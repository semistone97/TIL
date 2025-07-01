-- 04-Update-dalete.sql

SELECT * FROM members;

UPDATE members SET email="oh@jun.seok" WHERE id=1;
UPDATE members SET id=0 WHERE id=3;


-- 데이터 삭제(Delete)
DELETE FROM members WHERE join_date='2025-06-30';