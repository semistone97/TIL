# p09.1.sql
## p09 예제 10번 다시 풀기.

-- 문제 10: 활성 고객 분석
-- 고객상태(최종구매일) [NULL(구매없음) | 활성고객 <= 30 < 관심고객 <= 90 관심고객 < 휴면고객]별로
-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석

USE practice;
SELECT * FROM sales;
SELECT * FROM customers;

SELECT
	c.customer_id,
    c.customer_name,
    COUNT(order_date) AS 주문수,
    SUM(s.total_amount) AS 매출액 ,
    CASE
		# WHEN MAX(order_date)=0 THEN '잠재고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=90 THEN '휴면고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=30 THEN '관심고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=0 THEN '활성고객'
        ELSE NULL
	END AS 고객상태
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY customer_id; # 고객 별로 묶어서 상태를 만들어냄.(t_a는 SUM으로 묶음)

-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석
SELECT
	고객상태,
    COUNT(customer_id) AS 고객수,
    SUM(주문수) AS 총주문건수,
    SUM(매출액) AS 총매출액,
    ROUND(AVG(매출액)) AS 평균주문금액
FROM (
SELECT
	c.customer_id,
    c.customer_name,
    COUNT(order_date) AS 주문수,
    SUM(s.total_amount) AS 매출액,
    CASE
		# WHEN MAX(order_date)=0 THEN '잠재고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=90 THEN '휴면고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=30 THEN '관심고객'
        WHEN DATEDIFF('2024-12-31',MAX(order_date))>=0 THEN '활성고객'
        ELSE NULL
	END AS 고객상태
FROM customers c
LEFT JOIN sales s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY customer_id) AS c_a
GROUP BY 고객상태
ORDER BY 고객상태 DESC;
	