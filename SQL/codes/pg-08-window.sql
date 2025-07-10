-- pg-08-window.sql
-- "이거 왜 안 되지?"를 해결해주는 게 윈도우라네요.
-- Window 함수의 핵심은 over()라는 구문에 있음.

SELECT
	AVG(amount)
FROM orders;
-- 이렇게 되면 평균금액 하나만 볼 수 있음.
-- 만약 이 데이터를 다른 데이터랑 같이 보려면?
SELECT
	AVG(amount)
FROM orders
GROUP BY customer_id;
-- 여기는 고객별 구매액 평균
-- 위에 거랑 동시에 보는 건 불가능임.

-- 동시에 보려면?
SELECT
	order_id,
	customer_id,
	amount,
	ROUND(AVG(amount) OVER()) AS 전체평균
FROM orders
LIMIT 10;

-- ROW_NUMBER() -> 줄세우기 [ROW_NUMBER() OVER(ORDER BY 정렬기준)]
-- 주문금액이 높은 순서로 정렬
SELECT
	order_id,
	customer_id,
	amount,
	ROW_NUMBER() OVER(ORDER BY amount DESC) as 호구번호
FROM orders
ORDER BY 호구번호
LIMIT 20 OFFSET 40;

-- 주문 날짜가 최신인 순서대로 번호 매기기
SELECT
	order_id,
	customer_id,
	amount,
	order_date,
	ROW_NUMBER() OVER(ORDER BY order_date DESC) as 주문순서,
	RANK() OVER(ORDER BY order_date DESC) as 랭크,			-- 사람기준 랭크
	DENSE_RANK() OVER(ORDER BY order_date DESC) as 댄스랭크 	-- 점수기준 랭크
FROM orders
ORDER BY 주문순서; -- DESC


-- 7월 매출 TOP3 고객 찾기(이름, 7월 구입액, 순위)
WITH customer_total AS(
SELECT
	o.customer_id,
	c.customer_name AS 이름,
	SUM(o.amount) AS 월구매액
FROM orders o
LEFT JOIN customers c ON c.customer_id=o.customer_id
WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31' -- 날짜 쓸 때, MONTH()보다 BETWEEN 쓰는 게 더 좋음. 왜? INDEX 쓰기 어려움.
GROUP BY o.customer_id, c.customer_name
ORDER BY 월구매액
)
SELECT
	이름,
	월구매액,
	RANK() OVER(ORDER BY 월구매액 DESC) as 순위 -- 이걸 이렇게 최종 pt에 붙이지 말아라.
FROM customer_total
LIMIT 10;

-- 문제풀이 쌤 버전:
WITH july_sales AS (
	SELECT
		customer_id,
		SUM(amount) AS 월구매액
	FROM orders
	WHERE order_date BETWEEN '2024-07-01' AND '2024-07-31'
	GROUP BY customer_id
),
ranking AS (
	SELECT
		customer_id,
		월구매액,
		ROW_NUMBER() OVER(ORDER BY 월구매액 DESC) AS 순위
	FROM july_sales
)
SELECT
	r.customer_id,
	c.customer_name,
	r.월구매액,
	r.순위
FROM ranking r
INNER JOIN customers c ON r.customer_id=c.customer_id
WHERE r.순위 <= 10;



-- 각 지역에서 매출 1위 고객 -> ROW_NUMVER()로 숫자를 매기고, 이 컬럼 값이 1인 사람
-- 각 지역에서 총구매액 1위 고객 => ROW_NUMBER() 로 숫자를 매기고, 이 컬럼의 값이 1인 사람
-- [지역, 고객이름, 총구매액]
-- CTE
-- 1. 지역-사람별 "매출 데이터" 생성 [지역, 고객id, 이름, 해당 고객의 총 매출]
-- 2. "매출데이터" 에 새로운 열(ROW_NUMBER) 추가
WITH customer_amount AS(
	SELECT
		region AS 지역,
		customer_id AS 고객id,
		SUM(amount) AS 매출
	FROM orders
	GROUP BY customer_id,region
),
ranking AS(
	SELECT
		c.region AS 지역,
		ca.고객id,
		c.customer_name AS 이름,
		ROUND(ca.매출) AS 총매출,
		ROW_NUMBER() OVER(PARTITION BY c.region ORDER BY ca.매출 DESC) AS 지역순위,
		ROW_NUMBER() OVER(ORDER BY ca.매출 DESC) AS 전체순위
	FROM customer_amount ca
	LEFT JOIN customers c ON c.customer_id=ca.고객id
)
SELECT
	지역,
	이름,
	총매출,
	지역순위
FROM ranking
WHERE 지역순위<4;