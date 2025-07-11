-- 2-3.
-- 2020년 이전에 가입한 고객 목록
-- 2020년 1월 1일 이전에 첫 인보이스를 발행한 고객의 customer_id, first_name, last_name, 첫구매일을 조회하세요.

SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	MIN(i.invoice_date) AS 첫구매일
FROM customers c
LEFT JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,	c.first_name,c.last_name
HAVING MIN(i.invoice_date) < '2010-01-01'
ORDER BY 첫구매일;