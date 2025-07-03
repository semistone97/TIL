# JOIN을 시작하기 전에, 테이블 2개 이상일 때, 합쳐서 보려면 어떻게 해야할까?

# 18-join.sql
USE lecture;
	
SELECT
	*,
	(
    SELECT customer_name FROM customers c
    WHERE c.customer_id = s.customer_id
    ) AS 주문고객이름
FROM sales s;
# 레퍼런스 하는 식으로 빌려오는 건 쿼리가 너무 길어짐.
# 그래서 JOIN을 쓰는 거다.

SELECT
	*
FROM customers c # customer(c)에서 찾는데 
INNER JOIN sales s ON c.customer_id=s.customer_id; #키를 중심으로 sales(s)도 합쳐버림

SELECT
	c.customer_id,
    c.customer_type,
    s.total_amount
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id;

# 합치는 순서는 어떤 정렬을 기준으로 하느냐의 차이일 듯

# JOIN의 가장 기본형(키를 기준으로 붙이기)
SELECT * FROM customers c
INNER JOIN sales s ON c.customer_id=s.customer_id;

SELECT * FROM customers c
JOIN sales s;
# 이렇게 하면, customer 50명 x sales 120개를 곱해버림

# JOIN에도 여러 종류가 있음(INNER OUTER LEFT RIGHT)
## LEFT JOIN -> 왼쪽 테이블의 모든 데이터와 매칭되는 오른쪽 데이터, 오른쪽이 없어도 등장(왼쪽 테이블을 기준으로 한다는 것)
## INNER JOIN -> 양쪽 테이블을 모두 만족하는 경우
SELECT
	c.customer_id,
    c.customer_name
    # COUNT(s.id) AS 주문횟수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.id IS NULL;

SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    SUM(s.total_amount)
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;


SELECT
	category,
    product_name,
	COUNT(*),
    ROUND(SUM(total_amount))
FROM sales
GROUP BY category, product_name
ORDER BY category, product_name;


# JOIN을 가미한 그루핑 여러번
SELECT
	c.customer_id AS 고객번호,
    c.customer_name,
    c.customer_type,
	COUNT(*) AS 구매건수,
    ROUND(SUM(s.total_amount)) AS 총구매액,
    ROUND(AVG(s.total_amount)) AS 평균구매액,
    CASE
		WHEN COUNT(*) = 0 THEN '잠재고객'
        WHEN COUNT(*) >= 3 THEN '충성고객'
		ELSE '일반고객'
	END AS 활성도
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;
GROUP BY c.customer_id;

SELECT * FROM customers;
SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
	COUNT(s.id) AS 구매건수,
    COALESCE(SUM(s.total_amount)) AS 총구매액,
    COALESCE(AVG(s.total_amount)) AS 평균구매액,
    CASE
		WHEN COUNT(s.id) = 0 THEN '잠재고객'
        WHEN COUNT(s.id) >= 3 THEN '충성고객'
		ELSE '일반고객'
	END AS 활성도
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;


SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 구매건
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;

SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type,
    COUNT(s.id) AS 구매건수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;
# Strict Mode는 c.customer_id,c.customer_name, c.customer_type를 전부 넣는 게 맞음
# aggr 아닌 컬럼은 전부 그룹핑 해주도록 하세요.