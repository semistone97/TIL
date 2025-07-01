-- p04.sql

USE practice;

DESC userinfo;
SELECT * FROM userinfo;

INSERT INTO userinfo (nickname, phone, email) VALUES
('박지성', '01020022002', 'jspark@gmail.com'),
('홍진호', '01022222222', 'popung@zerg.com'),
('박근혜', '01020177777', NULL);

SELECT * FROM userinfo WHERE id>20;
SELECT * FROM userinfo WHERE email LIKE '%@gmail.com';
-- gmail or zerg.com 하려면?
SELECT * FROM userinfo WHERE email LIKE '%gmail.com' OR name LIKE '%박%';
SELECT * FROM userinfo WHERE email LIKE '%gmail.com' AND name LIKE '%박%';
SELECT * FROM userinfo WHERE name IN('박지성', '홍진호');
-- OR 쓰면?
SELECT * FROM userinfo WHERE name = 'not_bob' OR name = 'malphew';

SELECT * FROM userinfo WHERE email IS NULL; -- 머임 왜 안 됨
-- =는 안 되고 IS는 되는 이유? NULL은 값이 아니기 때문.
-- email이 비어있지 않은 사람은 그럼?
SELECT * FROM userinfo WHERE email IS NOT NULL;

SELECT * FROM userinfo WHERE name LIKE '%박%';
SELECT * FROM userinfo WHERE phone LIKE '010%';

SELECT * FROM userinfo WHERE 
(name LIKE '%홍%' OR 
name LIKE '%박%') AND 
email LIKE '%gmail.com';

ALTER TABLE userinfo CHANGE nickname name VARCHAR(20);