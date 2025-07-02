# 13-aggr-func.sql

USE lecture;
SELECT * FROM sales;

SELECT COUNT(id) AS 매출건수
FROM sales;

SELECT COUNT(customer_id)
FROM sales;

SELECT 
	COUNT(*) AS 총주문건수,
    COUNT(DISTINCT customer_id) AS 고객수,
    COUNT(DISTINCT product_name) AS 제품수
FROM sales;

# 총합
SELECT
	FORMAT(SUM(total_amount),0) AS 총매출액,
    SUM(quantity) AS 총판매수량
FROM sales;

SELECT
	SUM(IF(region='서울', total_amount, 0)) AS 서울매출, # 매번 판단을 해야하는 멍청이 코드
    SUM(
		IF(
			category='전자제품', total_amount, 0
		)
	) AS 전자매출
FROM sales;

SELECT SUM(total_amount) 
FROM sales
WHERE region='서울';

# AVG(평균)
SELECT
	AVG(total_amount) AS 평균매출액,
    AVG(quantity) AS 평균판매수량,
    FORMAT(ROUND(AVG(unit_price)),0) AS 평균단가
FROM sales;


# MIN MAX
SELECT
	MIN(total_amount) AS 최소매출액,
    MAX(total_amount) AS 최대매출액,
    MIN(order_date) AS 첫주문일,
    MAX(order_date) AS 마지막주문일
FROM sales;
