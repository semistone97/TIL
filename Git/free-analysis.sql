-- 요일별 장르선호도
WITH total AS (
SELECT
	i.invoice_id,
	EXTRACT(DOW FROM i.invoice_date) AS 요일번호,
	TO_CHAR(invoice_date, 'Dy') AS 요일문자,
	g.genre_id,
	g.name AS genre_name
FROM invoices i
INNER JOIN invoice_items ii ON i.invoice_id=ii.invoice_id
INNER JOIN tracks t ON ii.track_id=t.track_id
INNER JOIN genres g ON g.genre_id=t.genre_id
)
																				-- SELECT * FROM total;
SELECT
	-- 요일번호,
	요일문자,
	genre_name,
	RANK() OVER(PARTITION BY 요일번호 ORDER BY COUNT(*) DESC) AS genre_rank,
	COUNT(*) AS genre_pref_count
FROM total
GROUP BY 요일번호, 요일문자, genre_name
ORDER BY 요일번호, genre_pref_count DESC;