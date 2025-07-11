-- 3-2.
-- 장르별 상위 3개 아티스트 및 트랙 수
-- 각 장르별로 트랙 수가 가장 많은 상위 3명의 아티스트(artist_id, name, track_count)를 구하세요.
-- 동점일 경우 아티스트 이름 오름차순 정렬.

WITH genre_total AS(
SELECT
	tr.track_id AS track,
	tr.album_id AS album,
	al.artist_id AS artist,
	ar.name AS artist_name,
	gr.genre_id AS genre_id,
	gr.name AS genre
FROM tracks tr
LEFT JOIN albums al ON al.album_id = tr.album_id
LEFT JOIN artists ar ON ar.artist_id = al.artist_id
LEFT JOIN genres gr ON gr.genre_id = tr.genre_id
),
genre_rank AS (
SELECT
	genre,
	artist_name,
	COUNT(track) AS track_count,
	RANK() OVER(PARTITION BY genre ORDER BY COUNT(track) DESC, artist_name) AS ranking
FROM genre_total
GROUP BY artist_name, genre
)
SELECT
	genre,
	artist_name,
	track_count
FROM genre_rank
WHERE ranking<4;

