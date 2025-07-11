-- --3-5.
-- 최근 1년간 월별 신규 고객 및 잔존 고객
-- 최근 1년(마지막 인보이스 기준 12개월) 동안,
-- 각 월별 신규 고객 수와 해당 월에 구매한 기존 고객 수를 구하세요.

WITH monthly AS(
	SELECT
		DATE_TRUNC('month',invoice_date) AS c_month
	FROM invoices
	-- WHERE invoice_date BETWEEN '2013-01-01' AND '2013-12-31'
	GROUP BY c_month
	ORDER BY c_month
),
															-- SELECT * FROM monthly;
cust_repeat AS(
	SELECT
		customer_id,
		DATE_TRUNC('month',MIN(invoice_date)) AS min_month,
		RANK() OVER(PARTITION BY customer_id ORDER BY invoice_date) AS cus_rpt
	FROM invoices
	GROUP BY customer_id, invoice_date
)
															-- SELECT * FROM cust_repeat ORDER BY min_month;
, new_cust AS(
SELECT
	min_month,
	COUNT(customer_id) AS 신규고객
FROM cust_repeat
WHERE cus_rpt=1
GROUP BY min_month
ORDER BY min_month
)
															-- SELECT * FROM new_cust;
, old_cust AS(
SELECT
	min_month,
	COUNT(customer_id) AS 기존고객재구매
FROM cust_repeat
WHERE cus_rpt>1
GROUP BY min_month
ORDER BY min_month
)
															-- SELECT * FROM old_cust;
SELECT
	m.c_month AS 월,
	COALESCE(n.신규고객,0) AS 신규고객,
	COALESCE(o.기존고객재구매,0) AS 기존고객
FROM monthly m
LEFT JOIN new_cust n ON m.c_month=n.min_month
LEFT JOIN old_cust o ON m.c_month=o.min_month;

