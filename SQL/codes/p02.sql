-- p02.sql

USE practice;
SELECT * FROM userinfo;

INSERT INTO userinfo (nickname, phone) VALUES
	('malphew','010141414'),
    ('bob','010222'),
    ('guldan','010444444'),
    ('deathw','01010001'),
    ('bob','010325832');

SELECT * FROM userinfo WHERE id=11;
SELECT * FROM userinfo WHERE nickname='bob';
UPDATE userinfo SET nickname='not_bob' WHERE id=12;
-- 조회는 DB에서 가장 약한 권한.
UPDATE userinfo SET phone='01099998888' WHERE id=15;
DELETE FROM userinfo WHERE id=15;