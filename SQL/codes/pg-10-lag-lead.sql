-- pg-10-lag-lead.sql
-- LAG() : "렉걸린다"의 걔 맞음. 이전의 값을 가져옴.
-- 이걸 바탕으로 전월 대비 매출 분석
WITH monthly_sales AS(
	SELECT
		DATE_TRUNC('month',order_date) AS 월, --TRUNC: 뒤쪽 데이터 날리는 것.
		SUM(amount) AS 월매출--월 뽑는 건 외울 필요 없다카이
	FROM orders
	GROUP BY 월
)
SELECT
	TO_CHAR(월,'YYYY-MM') AS 년월,
	월매출,
	LAG(월매출,1) OVER(ORDER BY 월) AS 전월매출,
	월매출 - LAG(월매출,1) OVER(ORDER BY 월) AS 증감액,
	CASE
		WHEN LAG(월매출,1) OVER(ORDER BY 월) IS NULL THEN NULL
		ELSE ROUND(
			(월매출-LAG(월매출,1) OVER(ORDER BY 월))*100
			/
			LAG(월매출,1) OVER(ORDER BY 월)
		,2)::TEXT --||"%"
	END AS 증감률 
FROM monthly_sales
ORDER BY 월;

-- 아래는 깔끔한 버전(쌤)

-- 고객별 다음 구매를 예측
-- 최종적으로 [고객id, 주문일, 구매액, 다음구매일, 구매간격(일수), 다음구매액수, 금액차이]
-- ORDER BY customer_id, order_date LIMIT 10;

WITH daily_sales AS(
	SELECT
		DATE_TRUNC('DAY',order_date) AS 일, --TRUNC: 뒤쪽 데이터 날리는 것.
		SUM(amount) AS 일매출--월 뽑는 건 외울 필요 없다카이
	FROM orders
	GROUP BY 일
)
SELECT
	customer_id,
	order_date,
	amount,
	LEAD(order_date,1) OVER(ORDER BY order_date) AS 다음구매일,
	
FROM daily_sales
LEFT JOIN ;
--히힛 모르겠다. 답을 베끼자.
WITH customer_total AS(
SELECT
	customer_id AS 고객id,
	order_date AS 주문일,
	amount AS 금액,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS 구매순서,
	LAG(order_date,1) OVER(PARTITION BY customer_id ORDER BY order_date) AS 이전구매일,
	LAG(amount,1) OVER(PARTITION BY customer_id ORDER BY order_date) AS 이전구매액,
	LEAD(order_date,1) OVER(PARTITION BY customer_id ORDER BY order_date) AS 다음구매일,
	LEAD(amount,1) OVER(PARTITION BY customer_id ORDER BY order_date) AS 다음구매액,
	SUM(amount) OVER(PARTITION BY customer_id ORDER BY order_date) AS 누적구매금액,
	ROUND(AVG(amount) OVER(PARTITION BY customer_id ORDER BY order_date)) AS 누적평균구매금액
FROM orders
ORDER BY customer_id, order_date
)
SELECT
	고객id,
	주문일,
	금액,
	구매순서,
	주문일 - 이전구매일 AS 이전구매간격,
	다음구매일 - 주문일 AS 다음구매간격,
	(금액 - 이전구매액) AS 금액변화,
	ROUND((금액 - 이전구매액)/이전구매액,2) AS 금액변화율,
	누적구매금액,
	누적평균구매금액
FROM customer_total;
