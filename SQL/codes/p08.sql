# p08.sql



USE practice;

CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE products AS SELECT * FROM lecture.products;
CREATE TABLE customers AS SELECT * FROM lecture.customers;

#1. 단일값 서브쿼리
#1-1. 평균 이상 매출 주문들(성과가 좋은 주문들)
SELECT * FROM sales
WHERE total_amount >= (SELECT AVG(total_amount) FROM sales)
ORDER BY total_amount DESC;
## 평균 
SELECT AVG(total_amount) FROM sales;
#1-2. 최고 매출 지역의 모든 주문들

SELECT * FROM sales
WHERE region =(
SELECT region
FROM sales
GROUP BY region
ORDER BY SUM(total_amount) DESC LIMIT 1);
# 최고매출지역
SELECT region FROM sales WHERE total_amount = (SELECT MAX(total_amount) FROM sales)
;
# 지역매출
SELECT region
FROM sales
GROUP BY region
ORDER BY SUM(total_amount) DESC LIMIT 1;

# 최고매출
SELECT SUM(total_amount) = MAX(SUM(total_amount)) FROM sales
GROUP BY region;



#1-3. 각 카테고리 별 평균보다 높은 주문들
SELECT * FROM sales
WHERE total_amount IN(total_amount > (SELECT AVG(total_amount) FROM sales
GROUP BY category));
# 카테고리별 평균(그룹 안 쓰고, 마지막에 해보는 걸로)
SELECT AVG(total_amount) FROM sales
GROUP BY category;

SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM customers;
#2. 여러데이터 서브쿼리
#2-1. 기업 고객들의 모든 주문 내역(얘도 나중에)
SELECT * FROM sales
WHERE customer_id IN(
	SELECT DISTINCT customer_id FROM sales 
		WHERE customer_id IN(
		SELECT customer_type = '기업' FROM customers))
ORDER BY customer_id;
# 기업 고객
SELECT DISTINCT customer_id FROM customers 
	WHERE customer_id IN(
    SELECT customer_type = '기업' FROM customers)
ORDER BY customer_id;
#2-2. 재고 부족(50개 미만) 제품의 매출 내역
SELECT * FROM sales
WHERE product_name IN (SELECT product_name FROM products
WHERE stock_quantity < 50)
ORDER BY product_name;
# 재고부족 제품
SELECT product_name, stock_quantity FROM products
WHERE stock_quantity <50;
SELECT
	product_id
    
FROM products
WHERE stock_quantity < 50;

SELECT
	DISTINCT product_id
FROM sales
ORDER BY product_id;


#2-3. 상위 3개 매출 지역의 주문들
SELECT * FROM sales
WHERE region IN(SELECT region FROM sales
	GROUP BY region
    ORDER BY SUM(total_amount) DESC
    LIMIT 3);
# 지역 매출
SELECT region, SUM(total_amount) FROM sales
	GROUP BY region
    ORDER BY SUM(total_amount) DESC
    LIMIT 3;
#2-4. 상반기(24-01-01 ~ 24-06-30)에 주문한 고객들의 하납기(0701 ~ 1231) 주문 내역

# 하반기 주문 내역(2024년 데이터라고 가정하고)
SELECT *
FROM sales 
WHERE order_date >= '2024-07-01'
AND customer_id IN(
SELECT DISTINCT customer_id 
FROM sales
WHERE order_date < '2024-07-01');

# 상반기 주문 고객
SELECT DISTINCT customer_id FROM sales
WHERE order_date < '2024-07-01';