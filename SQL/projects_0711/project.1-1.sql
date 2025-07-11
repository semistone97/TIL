-- project 1-1

-- 모든 고객 목록 조회
-- 고객의 customer_id, first_name, last_name, country를 조회하고, customer_id 오름차순으로 정렬하세요.
SELECT
	customer_id,
	first_name,
	last_name,
	country
FROM customers
ORDER BY customer_id;