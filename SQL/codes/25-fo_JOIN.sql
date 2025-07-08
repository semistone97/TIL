#25-fo_JOIN.sql
## 이렇게 된 경우를 사용하는 게 언제냐? 거의 없음
## 있다고 하면 데이터의 무결성 검증을 위해...?
### MYSQL은 Full Outer JOIN이 없음.
### MySQL의 단점 : 추가적 기능을 full-fucntion으로 구현 XA
#### 그래서 구하는 법? 왼쪽 오른쪽 유니온

USE lecture;

SELECT 
	'LEFT에서' AS 출처	,
    c.customer_name,
    s.product_name
FROM customers c
LEFT JOIN sales ON c.customer_id

UNION

SELECT *
FROM customers c 
RIGHT JOIN sales s ON c.customer_id=s.customer_id
WHERE c.customer_id IS NULL