-- pg-06-CTE.sql
-- CTE(Common Table Expression): 쿼리 속의 '이름이 있는' 임시 테이블
-- 장점이 많음.

-- [평균 주문 금액]보다 큰 주문들의 고객정보

SELECT AVG(amount) FROM orders;

SELECT c.customer_name, o.amount
FROM customers c
INNER JOIN orders o ON c.customer_id=o.customer_id
WHERE o.amount > (SELECT AVG(amount) FROM orders)
LIMIT 10;

WITH avg_order AS(
	SELECT AVG(amount) AS avg_amount
	FROM orders
)
-- SELECT * FROM avg_order;

SELECT c.customer_name, o.amount, ao.avg_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN avg_order ao ON o.amount > ao.avg_amount
LIMIT 10;

-- 위쪽은 그냥 다 날아갔네.업데이트 쳐 안 해서 ㅎㅎㅎㅎㅎ
-- 문제1

-- 1. 각 지역별 고객 수와 주문 수를 계산하세요
-- 2. 지역별 평균 주문 금액도 함께 표시하세요
-- 3. 고객 수가 많은 지역 순으로 정렬하세요

-- - 먼저 지역별 기본 통계를 CTE로 만들어보세요
-- - 그 다음 고객 수 기준으로 정렬하세요
-- 지역    고객수   주문수   평균주문금액
-- 서울    143     7,234   567,890
-- 부산    141     6,987   534,123
-- 대구    140     6,876   545,678

WITH region_summary AS( -- 위쪽을 로직으로 보고
SELECT
	o.region AS 지역,
	COUNT(DISTINCT c.customer_id) AS 고객수,
	COUNT(order_id) AS 주문수,
	AVG(amount) AS 평균주문금액
FROM customers c
INNER JOIN orders o ON c.customer_id=o.customer_id
GROUP BY o.region -- CTE 쓰는 게 뭔지를 모르겠어여...
) -- region_summary라는 이름으로 전체를 묶음.
SELECT -- 아래쪽을 presentation으로 보기.(모듈화와 정리에 강점이 있는 쿼리다.)
	지역,
	고객수,
	주문수,
	ROUND(평균주문금액) AS 평균주문금액
FROM region_summary
ORDER BY 고객수 DESC;

SELECT
	region AS 지역,
	COUNT(customer_id) AS 고객수
FROM customers
GROUP BY region
ORDER BY COUNT(customer_id) DESC;

-- 문제2
-- 1. 각 상품의 총 판매량과 총 매출액을 계산하세요
-- 2. 상품 카테고리별로 그룹화하여 표시하세요
-- 3. 각 카테고리 내에서 매출액이 높은 순서로 정렬하세요
-- 4. 각 상품의 평균 주문 금액도 함께 표시하세요
-- - 먼저 상품별 판매 통계를 CTE로 만들어보세요
-- - products 테이블과 orders 테이블을 JOIN하세요
-- - 카테고리별로 정렬하되, 각 카테고리 내에서는 매출액 순으로 정렬하세요
-- ---
-- 카테고리      상품명           총판매량   총매출액      평균주문금액   주문건수   상품가격
-- 전자제품      스마트폰 123     450       125,678,900   279,286       450       567,890
-- 전자제품      노트북 456       298       98,234,500    329,644       298       1,234,567
-- 전자제품      태블릿 789       356       87,654,321    246,197       356       890,123
-- 컴퓨터        키보드 234       567       45,678,900    80,563        567       123,456
-- 컴퓨터        마우스 345       678       34,567,890    50,982        678       89,012
-- 액세서리      이어폰 456       234       23,456,789    100,243       234       234,567

-- 문제 2번 my 답
WITH prod_summary AS(
SELECT
	product_id AS 상품명,
	COUNT(*) AS 총판매량,
	SUM(amount) AS 총매출액,
	AVG(amount) AS 평균주문금액
FROM orders
GROUP BY product_id
)
SELECT
	pd.category AS 카테고리,
	ps.상품명,
	ps.총판매량,
	ps.총매출액,
	ps.평균주문금액,
	pd.price AS 상품가격
FROM prod_summary ps
LEFT JOIN products pd ON ps.상품명 = pd.product_id
GROUP BY pd.category, ps.상품명, ps.총판매량,
	ps.총매출액,
	ps.평균주문금액,
	상품가격
ORDER BY pd.category, ps.총판매량 DESC;

-- 아래는 쌤 답
WITH product_sales AS(--쪼개놓은 CTE
SELECT
	p.category AS 카테고리,
	p.product_name AS 제품명,
	p.price AS 상품가격,
	SUM(o.quantity) AS 총판매량,
	SUM(o.amount) AS 제품총매출액,
	COUNT(o.order_id) AS 주문건수,
	AVG(o.amount) AS 평균주문금액
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.category, p.product_name, p.price
),
category_total AS (
SELECT
	카테고리 AS 카테고리,
	SUM(제품총매출액) AS 카테고리총매출액
FROM product_sales
GROUP BY 카테고리
)
SELECT
	ps.카테고리,
	ps.제품명,
	-- ps.제품총매출액,
	-- ct.카테고리총매출액,
	ROUND(ps.제품총매출액/ct.카테고리총매출액,2)*100 AS 카테고리매출비중
FROM product_sales ps
INNER JOIN category_total ct ON ps.카테고리=ct.카테고리
ORDER BY ps.카테고리, ps.제품총매출액 DESC;


-- 문제3.고객 구매금액에 따라 VIP / 일반 / 신규로 등급통계 내기.
-- 최종목표 : 고객별 등급, 등급별 회원수, 등급별 총판매액, 등급별 평균주문수
-- 등급 기준 : VIP_상위 20%, 일반_전체평균보다위, 신규_나머지

-- VIP 기준 찾기
-- vip cut
WITH
customer_total AS (
	SELECT
		customer_id AS c_id,
		SUM(amount) AS c_amount,
		COUNT(*) AS c_order
	FROM orders
	GROUP BY customer_id
),
cust_cut AS(
SELECT
	AVG(c_amount) AS nml_cut,
	-- 상위 20% 기준값.(이게 너무 어려움...)
	PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY c_amount) AS vip_cut
FROM customer_total
),
grade AS(
SELECT
	ct.c_id,
	ct.c_amount,
	CASE
		WHEN ct.c_amount >= cc.vip_cut THEN 'VIP'
		WHEN ct.c_amount >= cc.nml_cut THEN 'normal'
		ELSE 'newbie'
	END AS cust_grade
FROM customer_total ct
CROSS JOIN cust_cut cc
)
SELECT
	cust_grade,
	COUNT(*) AS 등급별고객수,
	SUM(c_amount) AS 등급별총구매액
FROM grade
GROUP BY cust_grade;