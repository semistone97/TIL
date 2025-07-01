# p05.sql

USE practice;

SELECT* FROM userinfo;

ALTER TABLE userinfo ADD COLUMN age INT DEfAULT 20;
UPDATE userinfo SET age=30 WHERE id BETWEEN 11 AND 15;

SELECT * FROM userinfo ORDER BY name DESC LIMIT 3;
SELECT * FROM userinfo WHERE email LIKE '%gmail.com' ORDER BY age DESC;
SELECT name, phone, age FROM userinfo ORDER BY age AND phone LIMIT 3;
SELECT * FROM userinfo ORDER BY age DESC LIMIT 3 OFFSET 1; -- 순서 조회 중 가장 빠른 사람 제외

