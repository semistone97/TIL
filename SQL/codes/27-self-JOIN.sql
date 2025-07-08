# 27-self-JOIN.sql

USE lecture;

SELECT * FROM employees;
# 같은 테이블을 합치는 것이 SELF-JOIN

SELECT
	상사.name AS 상사명,
    직원.name AS 직원명
FROM employees 상사
LEFT JOIN employees 직원 ON 직원.id = 상사.id+1;

# M:N이 제일 많이 나오는 케이스 중 하나. 팔로우는 어떻게 만들어야 할까?
## 사실 follow는 self-JOIN 아님

# 고객 간 구매 패턴 유사성
## 손님1과 손님2의 공통 구매 카테고리 수, 공통 카테고리 이름(GROUP_CONCAT)
SELECT
	GROUP_CONCAT(c1.customer_name) AS 고객1,
    s.category,
    GROUP_CONCAT(c2.customer_name) AS 고객2
FROM sales s
INNER JOIN customers c1 ON c1.customer_id = s.customer_id
INNER JOIN customers c2 ON c2.customer_id = s.customer_id
GROUP BY 고객1, 고객2
#GROUP BY 고객1, 고객2
;
# 위는 MY 오답.
# 아래는 쌤 정답.

SELECT 
	c1.customer_id AS "id#1",
    c1.customer_name AS 고객1,
    c2.customer_id AS "id#2",
    c2.customer_name AS 고객2,
    
    COUNT(DISTINCT s1.category) AS 겹수,
    GROUP_CONCAT(DISTINCT s1.category) AS 공통카테고리
FROM customers c1
INNER JOIN sales s1 ON c1.customer_id = s1.customer_id
INNER JOIN customers c2 ON c1.customer_id < c2.customer_id # 1번 손님과 다른 사람을 고르는 중
INNER JOIN sales s2 ON s2.customer_id = c2.customer_id
	AND s1.category = s2.category
GROUP BY c1.customer_id, c1.customer_name, c2.customer_id, c2.customer_name;


