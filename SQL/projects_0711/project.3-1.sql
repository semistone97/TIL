-- 3-1
-- 월별 매출 및 전월 대비 증감률
-- 각 연월(YYYY-MM)별 총 매출과, 전월 대비 매출 증감률을 구하세요.
-- 결과는 연월 오름차순 정렬하세요.
WITH monthly_sales AS(
	SELECT
		DATE_TRUNC('month',invoice_date) AS 월,
		SUM(total) AS 월매출--월 뽑는 건 외울 필요 없다카이
	FROM invoices
	GROUP BY 월
	ORDER BY 월
)
SELECT
	TO_CHAR(월,'YYYY-MM') AS 년월,
	월매출,
	ROUND((월매출 - COALESCE(LAG(월매출,1) OVER(ORDER BY 월),0))/LAG(월매출,1) OVER(ORDER BY 월)*100,3) AS 증감액
FROM monthly_sales;
