-- 2-2.
-- 가장 많이 팔린 트랙 TOP 5
-- 판매량(구매된 수량)이 가장 많은 트랙 5개(track_id, name, 총 판매수량)를 출력하세요.
-- 동일 판매수량일 경우 트랙 이름 오름차순 정렬하세요.

SELECT
	ii.track_id,
	tr.name,
	SUM(ii.quantity) AS 총판매수량
FROM invoice_items ii
LEFT JOIN tracks tr ON ii.track_id=tr.track_id
GROUP BY ii.track_id, tr.name
ORDER BY 총판매수량 DESC, tr.name
LIMIT 5;