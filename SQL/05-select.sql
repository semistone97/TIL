-- 05-select.sql

USE lecture;
SELECT * FROM members;

#  모든 컬럼, (조건)id=4
SELECT * FROM members WHERE id=4;

# 이름, 이메일만 가져오기.
SELECT name, email FROM members;

SELECT name FROM members WHERE name='오준석';