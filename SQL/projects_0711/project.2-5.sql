-- 2-5.
-- 각 고객의 최근 구매 내역
-- 각 고객별로 가장 최근 인보이스(invoice_id, invoice_date, total) 정보를 출력하세요.
SELECT
	c.customer_id,
	CONCAT(c.first_name,c.last_name),
	i.invoice_id,
	MIN(i.invoice_date),
	SUM(i.total)
FROM customers c
LEFT JOIN invoices i ON i.customer_id = c.customer_id
GROUP BY c.customer_id, i.invoice_id