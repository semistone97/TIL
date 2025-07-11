-- 1-5.
-- 각 장르별 트랙 수 집계
-- 각 장르(genres.name)별로 트랙 수를 집계하고, 트랙 수 내림차순으로 정렬하세요.

SELECT
	g.name,
	COUNT(t.track_id) AS 트랙수
FROM tracks t
LEFT JOIN genres g ON t.genre_id=t.genre_id
GROUP BY g.name, t.genre_id
ORDER BY 트랙수 DESC;