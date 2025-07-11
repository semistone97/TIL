-- -- 3-4. 재도전
-- 국가별 재구매율(Repeat Rate)
-- 각 국가별로 전체 고객 수, 2회 이상 구매한 고객 수, 재구매율을 구하세요.
-- 결과는 재구매율 내림차순 정렬.

WITH cct AS(
	SELECT
		billing_country AS con,
		customer_id AS cust,
		COUNT(*) AS 구매횟수
	FROM invoices
	GROUP BY billing_country, customer_id
)
																-- SELECT * FROM cct;
, uniq_cust AS(
SELECT
	con,
	COUNT(DISTINCT cust) AS 전체고객수
FROM cct
GROUP BY con
)
																-- SELECT * FROM uniq_cust;
, morethan2 AS(
SELECT
	con,
	COUNT(cust) AS 재구매고객
FROM cct
WHERE 구매횟수 > 6
GROUP BY con
)
																-- SELECT * FROM morethan2;
SELECT
	uc.con,
	uc.전체고객수,
	mt2.재구매고객,
	ROUND(COALESCE(mt2.재구매고객,0)*100/uc.전체고객수,2) AS 재구매율
FROM uniq_cust uc
LEFT JOIN morethan2 mt2 ON uc.con=mt2.con
ORDER BY 재구매율 DESC;
