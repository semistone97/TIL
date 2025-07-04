# 21-view.sql
## VIEW를 저장하는 법.
USE lecture;

CREATE VIEW customer_summary AS 
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 주문횟수,
    COALESCE(SUM(s.total_amount), 0) AS 총구매액,
    COALESCE(AVG(s.total_amount), 0) AS 평균주문액,
    COALESCE(MAX(s.order_date), '주문없음') AS 최근주문일
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_type;

SELECT
	customer_type,
    SUM(총구매액),
    AVG(총구매액)
FROM customer_summary
GROUP BY customer_type;
SELECT * FROM customer_summary;
# 충성고객: 주문횟수 5이상
SELECT
	customer_name,
    주문횟수
FROM customer_summary
WHERE 주문횟수 >= 5;

# 잠재고객: 최근 주문 빠른 10명
SELECT
	customer_name,
    최근주문일
FROM customer_summary
WHERE 최근주문일 != '주문없음'
ORDER BY 최근주문일 DESC
LIMIT 10;
# 카테고리별 성과 요약
