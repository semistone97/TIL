#15-having.sql
USE lecture;


# WHERE와 HAVING은 비슷한 듯 용도가 다르다.
SELECT
	category AS 카테고리,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액

FROM sales
WHERE total_amount >= 100000 # 10만원 이상인 애들의 합을 본 것.(원본 데이터에 필터링을 걸고 그룹핑하는 것)
# 그렇다면 합이 n이 넘어가는 것들은 어떻게 볼 것인가??
# 의 답이 아마 HAVING일 듯.
GROUP BY 카테고리;

SELECT
	category AS 카테고리,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액
FROM sales
GROUP BY 카테고리
HAVING SUM(total_amount) >= 10000000 ; # ***HAVING은 pivot table에 조건을 거는 것***


# 활성 고객 지역을 찾아보자.
SELECT
	region AS 지역,
    COUNT(DISTINCT customer_id) AS 고객,
    COUNT(*) AS 주문건수,
    SUM(total_amount) AS 총매출액
FROM sales
GROUP BY region
HAVING 주문건수 >= 20 AND 고객 >= 15 ;

# 우수 영업 사원
SELECT
	sales_rep AS 영업사원,
    COUNT(*) AS 사원별_주문건수,
    COUNT(DISTINCT customer_id) AS 사원별_고객수,
    SUM(total_amount) AS 사원별_매출액,
    COUNT(DISTINCT DATE_FORMAT(order_date, '%m월')) AS 활동월,
    ROUND(
		SUM(total_amount) / COUNT(DATE_FORMAT(order_date, '%m월'))
        ) AS 월평매
FROM sales
GROUP BY sales_rep
HAVING 월평매 >= 5*POWER(10,5)
ORDER BY 월평매 DESC;
# 월평균 매출액 500000 이상이면 우수

SELECT * FROM sales;