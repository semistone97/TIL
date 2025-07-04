# p09.sql

USE practice;

DROP TABLE sales;
DROP TABLE products;
DROP TABLE customers;

CREATE TABLE sales AS SELECT * FROM lecture.sales;
CREATE TABLE customers AS SELECT * FROM lecture.customers;
CREATE TABLE products AS SELECT * FROM lecture.products;

SELECT * FROM sales;
SELECT * FROM customers;
SELECT * FROM products;

# 01. 주문거래액이 가장 높은 10건의 주문의 고객명, 상품명, 주문금액
SELECT
	#ROW_NUMBER() OVER(ORDER BY sal DESC) AS '#', -> 번호매기기 실패
    c.customer_name AS 고객명,
    s.product_name AS 상품명,
    s.total_amount AS 주문금액
FROM sales s
INNER JOIN customers c ON c.customer_id = s.customer_id
ORDER BY total_amount DESC LIMIT 10;


# 02. 고객 유형별 [고객유형, 주문건수, 평균주문금액]을 높은순으로 정렬
SELECT
	c.customer_type AS 고객유형,
    COUNT(c.customer_id) AS 주문건수,
    ROUND(AVG(s.total_amount)) AS 평균주문금액
FROM sales s
INNER JOIN customers c ON c.customer_id = s.customer_id
GROUP BY c.customer_type
ORDER BY 평균주문금액 DESC;
-- 문제 1: 모든 고객의 이름과 구매한 상품명 조회
SELECT
	c.customer_name AS 고객이름,
    COALESCE(s.product_name) AS 구매한_상품명
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
ORDER BY c.customer_name;
# 없는 것도 뜬다. 히히
-- 문제 2: 고객 정보와 주문 정보를 모두 포함한 상세 조회
SELECT
	*
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;
-- 문제 3: VIP 고객들의 구매 내역만 조회
SELECT
	*
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_type='VIP';
-- 문제 4: 50만원 이상 주문한 기업 고객들
SELECT
	*
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
WHERE c.customer_type='기업'
AND (SELECT SUM(total_amount) FROM sales) >= 500000;
# WHERE c.customer_type='기업' AND s.total_amount >=500000;
-- 문제 5: 2024년 하반기(7월~12월) 전자제품 구매 내역
SELECT
	*
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.category='전자제품'
AND order_date BETWEEN '2024-07-01' AND '2024-12-31';
# 멋있게 쓰는 법 아래에 참고
# MONTH(s.order_date) BETWEEN 7 AND 12;

-- 문제 6: 고객별 주문 통계
SELECT
	c.customer_name AS 고객,
    SUM(total_amount) AS 총구매금액,
    ROUND(AVG(total_amount)) AS 평균구매금액,
    MAX(total_amount) AS 최고주문금액,
    MIN(total_amount) AS 최소주문금액
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- 문제 7: 모든 고객의 주문 통계
SELECT
	c.customer_name AS 고객,
    COALESCE(SUM(total_amount)) AS 총구매금액,
    COALESCE(ROUND(AVG(total_amount))) AS 평균구매금액,
    COALESCE(MAX(total_amount)) AS 최고주문금액,
    COALESCE(MIN(total_amount)) AS 최소주문금액
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_name;

-- 문제 8: 카테고리별 고객 유형 분석
SELECT
	s.category AS 카테고리,
    c.customer_type AS 고객유형,
    COUNT(DISTINCT c.customer_id) AS 카테고리고객수,
    COUNT(c.customer_id) AS 주문건수,
    SUM(total_amount) AS 금액총합
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY s.category, c.customer_type
ORDER BY s.category DESC, c.customer_type;

-- 문제 9: 고객별 등급 분류
SELECT
	c.customer_id AS 고객번호,
    c.customer_name AS 고객명,
    c.customer_type AS 등급
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id;
# GROUP BY c.customer_id; # 이게 뭔 문젠가여-> 고객 등급별 주문 통계 분석인가

-- 문제 9: 고객별 등급 분류
SELECT
	c.customer_id AS '#',
    c.customer_name AS 고객명,
	CASE
		WHEN COUNT(s.customer_id) >= 10 THEN 'Platinum'
        WHEN COUNT(s.customer_id) >= 5 THEN 'Gold'
        WHEN COUNT(s.customer_id) >= 3 THEN 'Silver'
        WHEN COUNT(s.customer_id) >= 0 THEN 'Bronze'
        ELSE 'NOT 고객'
	END AS 활동등급,
    CASE
		WHEN SUM(s.total_amount) >= 500000 THEN '로얄'
        WHEN SUM(s.total_amount) >= 200000 THEN '최우수'
        WHEN SUM(s.total_amount) >= 100000 THEN '우수'
        WHEN SUM(s.total_amount) >= 0 THEN '일반'
        ELSE '신규'
	END AS 구매등급
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;
-- 활동등급(구매횟수) : [0(잠재고객) < 브론즈 < 3 <= 실버 < 5 <= 골드 < 10 <= 플래티넘]
-- 구매등급(구매총액) : [0(신규) < 일반 <= 10만 < 우수 <= 20만 < 최우수 < 50만 <= 로얄]

-- 문제 10: 활성 고객 분석
-- 고객상태(최종구매일) [NULL(구매없음) | 활성고객 <= 30 < 관심고객 <= 90 관심고객 < 휴면고객]별로
-- 고객수, 총주문건수, 총매출액, 평균주문금액 분석
SELECT
	
    COUNT(DISTINCT c.customer_id) AS 고객수,
    COUNT(c.customer_id) AS 총주문건수,
    
    SUM(s.total_amount) AS 총매출액,
    CASE
		WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 90 THEN '휴면고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 30 THEN '관심고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) > 0 THEN '활성고객'
        ELSE NULL
	END AS 고객상태
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY 고객상태;
# 휴면 고객(3개월 이상 쉰 고객)
# INNER JOIN을 많이 쓰고, 가끔 LEFT JOIN 사용.

SELECT
	고객상태,
    COUNT(customer_id) AS 총주문건수,
    coalesce((SUM(total_amount),0)) AS 총매출액,
    coalesce(AVG(total_amount),0) AS 평균주문금액
FROM (SELECT
	c.customer_id,
    s.total_amount,
   ABS(DATEDIFF(s.order_date, '2024-12-31')) AS 얼마나지났,
    CASE
		WHEN MAX(order_date) IS NUll THEN '구매없음'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 90 THEN '휴면고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 30 THEN '관심고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) > 0 THEN '활성고객'
        ELSE NULL
	END AS 고객상태
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id) AS 활성상태파악
GROUP BY 고객상태
ORDER BY 고객상태 DESC ;

SELECT
	c.customer_id,
    s.total_amount,
   ABS(DATEDIFF(s.order_date, '2024-12-31')) AS 얼마나지났,
    CASE
		WHEN MAX(order_date) IS NUll THEN '구매없음'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 90 THEN '휴면고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) >= 30 THEN '관심고객'
        WHEN DATEDIFF('2024-12-31',MAX(s.order_date)) > 0 THEN '활성고객'
        ELSE NULL
	END AS 고객상태
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, ;

