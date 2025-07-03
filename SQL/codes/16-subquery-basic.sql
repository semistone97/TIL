# 16-subquery-basic.sql

USE lecture;

# Mission : 매출평균보다 더 높은 금액을 주문한 판매 데이터(*) 보여줘
SELECT
	AVG(total_amount)
FROM sales;

# SELECT * FROM sales WHERE total_amount  > AVG(total_amount);

# 서브쿼리
SELECT * FROM sales 
WHERE total_amount  > (SELECT AVG(total_amount) FROM sales);
# 이런 식으로 쿼리 안에 쿼리를 넣게 되는 것.

SELECT
	product_name AS 이름,
    total_amount AS 판매액,
    ROUND(total_amount - (SELECT AVG(total_amount) FROM sales)) AS 평균차이
	# 어떤 값을 기준으로 쿼리를 짜고 싶으면 자주 사용하게 되는 서브쿼리.
    # aggr-func의 자료를 사용하게 되는 것은 서브쿼리가 아니면 쓸 수 없음.
FROM sales
# 평균보다 더 주문한
WHERE total_amount > (SELECT AVG(total_amount) FROM sales);

# 데이터가 하나 나오는 경우(aggr)
SELECT AVG(quantity) FROM sales;
# 여태 배운 것들은 이런 식으로 하나의 값만 나오는 서브쿼리를 활용.

# (하나활용1)sales에서 가장 비싼 걸  시킨 주문.
SELECT * FROM sales WHERE total_amount = (SELECT MAX(total_amount) FROM sales);
# (하나활용2)가장 최근의 주문
SELECT * FROM sales WHERE order_date = (SELECT MAX(order_date) FROM sales);
SELECT * FROM sales GROUP BY order_date HAVING MAX(order_date);
# 아래처럼 쓰는 방법도 있지만, 성능면에서 차이가 있다고 함.(전체를 정렬해야 하기 때문에)
# + 최댓값이 여럿인 걸 반영하지 못 함
SELECT * FROM sales ORDER BY total_amount DESC LIMIT 1;
# (하나활용3)가장 평균과 유사한 주문데이터 5개
SELECT * FROM sales 
ORDER BY ABS((SELECT AVG(total_amount) FROM sales)-total_amount)
LIMIT 5;
# 평균값
SELECT AVG(total_amount) FROM sales;

# 데이터가 여러 개 나오는 경우
SELECT *
FROM sales;

SELECT * FROM customers;
SELECT * FROM sales;
SELECT * FROM products;