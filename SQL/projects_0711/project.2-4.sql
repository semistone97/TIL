-- 2-4.
-- 국가별 총 매출 집계 (상위 10개 국가)
-- 국가(billing_country)별 총 매출을 집계해, 매출이 많은 상위 10개 국가의 국가명과 총 매출을 출력하세요.

SELECT
	billing_country,
	SUM(total) AS 총매출
FROM invoices
GROUP BY billing_country
ORDER BY 총매출 DESC;