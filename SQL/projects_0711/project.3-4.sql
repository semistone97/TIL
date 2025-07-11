-- -- 3-4.
-- 국가별 재구매율(Repeat Rate)
-- 각 국가별로 전체 고객 수, 2회 이상 구매한 고객 수, 재구매율을 구하세요.
-- 결과는 재구매율 내림차순 정렬.
WITH con_cust_total AS (
SELECT
	billing_country AS 국가,
	customer_id,
	COUNT(customer_id) OVER(PARTITION BY billing_country) AS 전체고객수,
	COUNT(total) AS 인당횟수
FROM invoices
GROUP BY 국가, customer_id
ORDER BY 국가, customer_id
)
-- SELECT * FROM con_cust_total;
, morethan2 AS(
SELECT
	국가,
	전체고객수,
	COUNT(인당횟수) AS morethan2,
	CONCAT(ROUND(COUNT(인당횟수)*100/전체고객수,2),'%') AS 재구매율
FROM con_cust_total
WHERE 인당횟수 > 6
GROUP BY 국가, 전체고객수
)
SELECT * FROM morethan2;


SELECT
	*
FROM invoices
ORDER BY customer_id