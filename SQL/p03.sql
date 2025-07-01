-- p03.sql

USE practice;
DESC userinfo;
SELECT * FROM userinfo;

ALTER TABLE userinfo ADD COLUMN email VARCHAR(40) DEFAULT 'ex@gmail.com';
ALTER TABLE userinfo MODIFY COLUMN nickname VARCHAR(100);
ALTER TABLE userinfo DROP COLUMN reg_date;
UPDATE userinfo SET 
email='11@gmail.com' WHERE id=11;

UPDATE userinfo
SET email='12@gmail.com' 
WHERE id=12;

UPDATE userinfo
SET email='13@gmail.com' 
WHERE id=13;