#19-JOIN-GROUP.sql
# 이거는 뭐하다 놓쳤지...
# 원래는 18 JOIN, 19 JOIN-GROUP인데, 나는 19에 review 내용 넣는 걸로

USE lecture;
SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM customers;

INSERT INTO sales(id, order_date, product_name, category, customer_id, product_id, quantity, unit_price, total_amount, sales_rep, region)
			VALUES (121, '2025-07-04', '건전지','전자제품','fake','238123',3,10,1000,'없다고','tlqkgf') ;
# Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`lecture`.`sales`, CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`))
# 위의 에러는 왜 났을까? customer_id에 있는 'fake'가 """FOREIGN KEY (customer_id) REFERENCES customers(customer_id)"""를 충족하지 못해서.
# 쌤 말로는 원래 테이블의 id는 FOREIGN 제약을 걸고 하는 게 ```무조건``` 맞다고.


# INNER  JOIN은 교집합(둘 다 raw가 있는 컬럼이 있는 행끼리만 JOIN)
SELECT #습관 : SELECT 쓰고 뒤에 비워두기
	'1.INNER JOIN' AS 구분,
    COUNT(*) AS 줄수,
    COUNT(DISTINCT c.customer_id) AS 고객수
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
# 데이터가 붙어있을 때, 컬럼의 숫자가 그렇게 중요한가?  라고 하면 애매한 지점이 있음.
# 그럼에도 불구하고 "뭐가 앞에 오는 게 맞나?"에 대해서는 '주체'가 중요함.
# 특히 INNER JOIN은 앞뒤 순서의 차이가 정말 없음(데이터 상으로는)
# INNER JOIN을 하면 두 테이블의 빈 부분을 채우기 때문에 큰 쪽의 수에 맞춰서 감.

UNION # 위아래 쿼리 합치기

# LEFT JOIN : 왼쪽(FROM 뒤에 온) 테이블은 무조건 다 나옴.(INNER JOIN 뒤에 없더라도)
SELECT
	'2. LEFT JOIN' AS 구분,
    COUNT(*) AS 줄수,
    COUNT(DISTINCT c.customer_id) AS 고객수
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
# 이번엔 125가 됐다. 고객 수는 45에서 50이 됨
# WHY? customer 중 sales에 없는 사람이 5명.
# 전체 줄도 없던 사람 5명 추가돼서 125 ㅇㅇ

UNION

SELECT
	'3. 전체 고객수' AS 개쒸빨럼, #컬럼 이름은 알아서 맞춰주네. 다만 숫자가 안 맞으면 에러가 뜸
    COUNT(*) AS 줄수,
    COUNT(DISTINCT c.customer_id) AS 고객수
FROM customers c
RIGHT JOIN sales s ON c.customer_id = s.customer_id; # 여기는 sales 기준으로 해당하는 customer를 붙임
# 근데 FROM JOIN 순서를 바꾸면 되는 거라, RIGHT JOIN은 거의 안 씀.
# 참고로, RIGHT JOIN을 해도, 테이블 상에서는 FROM 뒤가 먼저 나옴.
#  그런 직관성이 떨어져서 안 쓰는 것도 있는 

SELECT
	*
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id