-- pg-09-partition.sql
-- 사무실에 있는 파티션 ㅇㅇ
-- 동 | 층 | 호수 | 이름으로 나눠진 파일인데 동에 따른 층을 보고 싶다면?
-- 데이터를 특정 그룹으로 나누고, window 함수로 결과를 확인

SELECT
	region,
	customer_id,
	amount,
	ROW_NUMBER() OVER(ORDER BY amount DESC) AS 전체순위,
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY amount DESC) AS 지역순위,
	RANK() OVER(ORDER BY amount DESC) AS 전체순위,
	RANK() OVER(PARTITION BY region ORDER BY amount DESC) AS 지역순위,
	DENSE_RANK() OVER(ORDER BY amount DESC) AS 전체순위,
	DENSE_RANK() OVER(PARTITION BY region ORDER BY amount DESC) AS 지역순위
FROM orders
LIMIT 10;
-- GROUP BY는 애초에 같이 못 나옴.
-- PARTITION은 이렇게 나눠서 순위를 볼 수 있게 해줌

-- SUM() OVER()
WITH daily_sales AS(
	SELECT
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT
	order_date,
	일매출,
	SUM(일매출) OVER(ORDER BY order_date) AS 누적매출 -- 누적 합계에 대한 원리는 그냥 그렇다고 이해해보자...
FROM daily_sales;

-- 월별 누적
WITH daily_sales AS(
	SELECT
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-06-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT
	order_date,
	일매출,
	SUM(일매출) OVER(ORDER BY order_date) AS 누적매출, -- 누적 합계에 대한 원리는 그냥 그렇다고 이해해보자...
	-- 위는 범위 내 계속 누적.
	SUM(일매출) OVER(
		PARTITION BY DATE_TRUNC('month', order_date)
		ORDER BY order_date
	) AS 월누적매출 -- 오옷, 냅다 누적이 아니라, 월단위로 초기화가 된다.
FROM daily_sales;

-- AVG() OVER()
-- 스마트폰 평균배터리 사용량같은 거.


-- 아 헐. 보통 파일 하나는 쿼리 하나를 쓰고 끝난대.
-- 아 맞네. SQL은 마지막 결과만 보여주는구나.
WITH daily_sales AS(
	SELECT
		order_date,
		SUM(amount) AS 일매출
	FROM orders
	WHERE order_date BETWEEN '2024-06-01' AND '2024-08-31'
	GROUP BY order_date
	ORDER BY order_date
)
SELECT
	order_date,
	일매출,
	ROUND(AVG(일매출) OVER(
		ORDER BY order_date
		ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
	)) AS 이동평균_앞뒤로이틀
FROM daily_sales;
-- 누적평균이 아니라, 이동평균을 보려는 목적임.
-- 측정하는 날짜 앞의 n일+오늘 만큼의 평균을 측정

SELECT
	region,
	order_date,
	amount,
	ROUND(AVG(amount) OVER(PARTITION BY region ORDER BY order_date)) AS 지역매출누적평균
FROM orders
WHERE order_date
BETWEEN '2024=07-01' AND '2024-07-02';
-- 이동평균을 확인하는 이유? 그 자체로 뭐라기보다 원소스라고 이해하는 게 나을 듯.(강사쌤은 추세파악이라고 하심)
-- 개인적으로 이해하기에는 개별 데이터가 튀는 것들을 막는 용도.

-- 카테고리 별 인기 상품(매출순위)
-- CTE
-- 상품카테고리, 상품id, 상품이름, 상품가격, 상품주문건수, 상품판매개수, 상품총매출
-- 위에서 만든 테이블에 window 함수 컬럼 추가 + 매출순위, 판매량 순위
-- 총데이터 표시
WITH sales AS(
	SELECT
		p.category AS 카테고리,
		p.product_id AS 상품id,
		p.product_name AS 이름,
		p.price AS 가격,
		o.amount AS 매출,
		o.quantity AS 개수
	FROM products p
	LEFT JOIN orders o ON p.product_id=o.product_id
),
p_sales AS(
SELECT
	카테고리,
	상품id,
	이름,
	가격,
	COUNT(매출) AS 건수,
	SUM(개수) AS 개수,
	SUM(매출) AS 총매출,
	ROW_NUMBER() OVER(PARTITION BY 카테고리 ORDER BY SUM(매출) DESC) AS 매출순위,
	ROW_NUMBER() OVER(PARTITION BY 카테고리 ORDER BY SUM(개수) DESC) AS 판매량순위
FROM sales
GROUP BY 카테고리, 상품id, 이름, 가격
)
SELECT
	*
FROM p_sales
WHERE 매출순위<4;


