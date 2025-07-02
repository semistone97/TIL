# 14-group-by.sql



SELECT
    category AS 카테고리, # 얘는 안 써도 됨 사실.
    COUNT(*) AS 주문건수,
	SUM(total_amount) AS 총매출,
    AVG(total_amount) AS 평균매출
FROM sales
GROUP BY category # category라는 컬럼을 기준으로 그룹핑을 진행한 것.
ORDER BY 총매출 DESC; # 기존 SELECT랑 다르게, 아예 새로운 테이블을 만든 거라, 참조가 가능함.

SELECT
	region,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 지역별매출,
    FORMAT(AVG(total_amount),1) AS 지역별평균매출,
    COUNT(DISTINCT customer_id) AS 지역별_고객수,
    COUNT(*)/COUNT(DISTINCT customer_id) AS 고객당주문수, # SELECT 구문 중이라 위의 AS를 참조할 수 없음.
    FORMAT(SUM(total_amount)/COUNT(DISTINCT customer_id),0) AS 고객당평균매출
FROM sales
GROUP BY region;

SELECT
	region AS 지역,
    category AS 카테고리,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 지역별매출,
    FORMAT(AVG(total_amount),1) AS 지역별평균매출,
    COUNT(DISTINCT customer_id) AS 지역별_고객수,
    COUNT(*)/COUNT(DISTINCT customer_id) AS 고객당주문수, # SELECT 구문 중이라 위의 AS를 참조할 수 없음.
    FORMAT(SUM(total_amount)/COUNT(DISTINCT customer_id),0) AS 고객당평균매출
FROM sales
GROUP BY region, category
ORDER BY region, 지역별매출 DESC; # 순서가 멧챠 중요하다

# 영업사원(sales_rep) 별 성과
SELECT
	sales_rep AS 사원,
    DATE_FORMAT(order_date, '%Y년 %m월') AS 월,
    SUM(total_amount) AS 월매출, #여기서 FORMAT을 하면 안 됨. 그렇게 되면 string 처리를 하게 된 것.
    # FORMAT은 최종적인 dashboard에 가서 쓰도록 할 것.
    COUNT(*) AS 주문건수,
    FORMAT(SUM(total_amount)/COUNT(*),0) AS 건당매출
FROM sales
GROUP BY sales_rep, 월
ORDER BY sales_rep, 월매출 DESC;

# 월별 매출 트렌드
SELECT
	DATE_FORMAT(order_date, '%Y년 %m월') AS 월,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 월매출,
    COUNT(DISTINCT customer_id) AS MAU
FROM sales
GROUP BY 월
ORDER BY 월;

# 요일별 매출 패턴

SELECT
	DAYNAME(order_date),
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 매출,
    COUNT(DISTINCT customer_id) AS WAU
FROM sales
GROUP BY DAYNAME(order_date), DAYOFWEEK(order_date)
ORDER BY 매출 DESC;


SELECT * FROM sales;
	