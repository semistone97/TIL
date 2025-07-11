-- 1-3.
-- 트랙(곡)별 단가와 재생 시간 조회
-- tracks 테이블에서 각 곡의 name, unit_price, milliseconds를 조회하세요.
-- 5분(300,000 milliseconds) 이상인 곡만 출력하세요.

SELECT
	name,
	unit_price,
	milliseconds
FROM tracks
WHERE milliseconds >= 300000;