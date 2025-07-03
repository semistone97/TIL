# 17-subquery-intermediate.sql
USE lecture;
SELECT * FROM customers;


# 스칼라 서브쿼리(1)말고, 벡터 서브쿼리(n)를 배울 예정.
# SELECT 뒤에 보여주는 게 뭔지에 따라 결정됨.
SELECT
	customer_id FROM customers WHERE customer_type = 'VIP';

# 모든 VIP의 주문내역
SELECT
	*
FROM sales
WHERE customer_id IN (
	SELECT customer_id FROM customers 
    WHERE customer_type = 'VIP'
)
ORDER BY total_amount DESC;
# 사실상 Vector를 서브쿼리로 사용하려면 웬만하면 IN이랑 같이 사용
SELECT * FROM sales;

# 전자제품을 구매한 고객들의 모든 주문을 보고 싶다
SELECT
	*
FROM sales
WHERE customer_id IN
(SELECT DISTINCT customer_id  FROM sales
WHERE category='전자제품');
# SELECT customer_id WHERE category='전자제품' FROM sales

# 여태까지의 서브쿼리는 모두 WHERE 절에 들어가고 있음.(벡터는 IN까지)