-- 3-3.
-- 고객별 누적 구매액 및 등급 산출
-- 각 고객의 누적 구매액을 구하고,
-- 상위 20%는 'VIP', 하위 20%는 'Low', 나머지는 'Normal' 등급을 부여하세요.
WITH customer_total AS(
	SELECT
		customer_id,
		SUM(total) AS acc_total
	FROM invoices
	GROUP BY customer_id
)
														-- SELECT * FROM customer_total;
,cust_grade AS(
	SELECT
		*,
		NTILE(5) OVER(ORDER BY acc_total DESC) AS _cut
	FROM customer_total
)
														-- SELECT * FROM cust_grade;
SELECT
	cg.customer_id,
	CONCAT(c.first_name, c.last_name),
	cg.acc_total,
	CASE
		WHEN cg._cut=1 THEN 'VIP'
		WHEN cg._cut=5 THEN 'Low'
		ELSE 'Normal'
	END AS grade
FROM cust_grade cg
LEFT JOIN customers c ON cg.customer_id=c.customer_id;