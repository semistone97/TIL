# 20-subquery-master.sql
## 이번 강의 : FROM절에 쓰는 SubQUery!
USE lecture;
# 각 고객의 주문정보		[cid, cname, ctype, 총주문횟수, 총주문금액, 최근주문일]
## 

SELECT * FROM sales;

# JOIN 안 쓰고, subquery만 보여주시는 중
## JOIN과 Subquery, GROUP은 용처가 다 다름

# 각 카테고리 평균매출 중에서 50만원 이상
SELECT
	category,
    ROUND(AVG(total_amount)) AS 평균매출
FROM sales
GROUP BY category
HAVING ROUND(AVG(total_amount)) >= 500000
ORDER BY 평균매출 DESC;
# HAVING은 사용처가 명확하게 정해져있음.

# SUBQUERY로 하는 법
SELECT *
FROM (
SELECT
	category,
    ROUND(AVG(total_amount)) AS 평균매출
FROM sales
GROUP BY category
) AS category_summary
WHERE 평균매출 >= 500000;
# 우리가 가상의 테이블을 만들어서 거기서 추출한다면? 이라는 내용
## Error Code: 1248. Every derived table must have its own alias
## 쪼개져 나온 테이블은 이름을 붙여야 함.
### FROM의 테이블을 쓰는 건 전체 테이블을 쪼개서 편집한 테이블을 사용한다는 뜻
### ```인라인 뷰(VIEW)```
#### HAVING은 그룹핑을 해야만 쓸 수 있지만, VIEW는 일반테이블처럼 쓸 수 있음
#### 

# 1. 카테고리별 매출 분석 후 필터링
## 카테고리 명, 주문건수, 총매출, 평균매출(0<저단가<400000<중단가<800000<고단가)
SELECT
	*,
	CASE
		WHEN avg_amount > 800000 THEN '고단가'
        WHEN avg_amount > 400000 THEN '중단가'
        WHEN avg_amount > 0 THEN '저단가'
		ELSE 'is the 0'
    END AS 필터링
FROM (SELECT
	category AS 카테고리명,
    COUNT(customer_id) AS 주문건수,
    SUM(total_amount) AS 총매출,
    ROUND(AVG(total_amount)) AS 평균매출,
    ROUND(AVG(total_amount)) AS avg_amount
FROM sales
GROUP BY category) AS avg_amount;


SELECT
	category,
    ROUND(AVG(total_amount)) AS avg_amount
FROM sales
GROUP BY category;
# 이렇게 만든 VIEW는 임시로 만드는 것 외에 항시 저장해놓는 것도 가능함.
## 왼쪾 UI 보면 저장하는 곳이 있음. 보통 view는 거기에 저장함.
### 저장 안 하면 in-line view. 

# 근데 그러면 그냥 테이블 만드는 거랑 뭐가 다른 거임????

# 영업사원별 성과 등급 분류[영업사원, 총매출액, 주문건수, 평균주문액, 매출등급, 주문등급]
# 매출등급: 총매출[0<C<1000000<B<3000000<A<5000000<S)
# 주문등급: 주문건수[0<C<15<B<30<A]
SELECT
	*,
    CASE
		WHEN 총매출액 > 5000000 THEN 'S'
        WHEN 총매출액 > 3000000 THEN 'A'
        WHEN 총매출액 > 1000000 THEN 'B'
        WHEN 총매출액 > 0 THEN 'C'
		ELSE 'is the 0'
    END AS 매출등급,
    CASE
		WHEN 주문건수 > 30 THEN 'A'
        WHEN 주문건수 > 15 THEN 'B'
        WHEN 주문건수 > 0 THEN 'C'
		ELSE 'is the 0'
    END AS 주문등급
FROM (SELECT
	sales_rep AS 영업사원,
    SUM(total_amount) AS 총매출액,
    COUNT(customer_id) AS 주문건수,
    AVG(total_amount) AS 평균주문액
FROM sales
GROUP BY sales_rep) AS c_a;


SELECT
	sales_rep AS 영업사원,
    SUM(total_amount) AS 총매출액,
    COUNT(customer_id) AS 주문건수,
    AVG(total_amount) AS 평균주문액
FROM sales
GROUP BY sales_rep;
