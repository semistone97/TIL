-- project 1-2.sql

-- 모든 앨범과 해당 아티스트 이름 출력
-- 각 앨범의 title과 해당 아티스트의 name을 출력하고, 앨범 제목 기준 오름차순 정렬하세요.
SELECT
	al.title,
	ar.name
FROM albums al
LEFT JOIN artists ar ON al.artist_id=ar.artist_id
ORDER BY al.title;