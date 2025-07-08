# 23-one-to-many.sql

USE lecture;
SELECT
	c.customer_id,
    c.customer_name,
    COUNT(s.id) AS 주문횟수,
    # 주문상품을 ,로 나열해서 보고싶을 땐?
    GROUP_CONCAT(s.product_name) AS 주문제품들
FROM customers c
LEFT JOIN sales s ON c.customer_id=s.customer_id
GROUP by c.customer_id, c.customer_name;
# 1:N 관계형에서는 대부분 LEFT JOIN을 활용하게 됨(선택사항이 대부분이다보니)