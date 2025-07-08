# 29-EXISTS.sqlc
## 성능에서 큰 차이를 보여줌(IN으로 대체할 수 있지만 이거 안 쓰면 원시인 돌도끼 ㅇㅇ)
USE lecture;

#1 전자제품을 구매한 고객 정보
SELECT
	customer_id,
    customer_name,
    customer_type
FROM customers c
WHERE customer_id IN(
	SELECT customer_id
	FROM sales s
    WHERE category='전자제품'
    );

# """IN"""을 쓰면 일단 테이블을 만들어야 해서, 메모리를 많이 잡아먹음. 이후 하나하나 대조하기 때문에 최적화 X
## sales에서 customer와 같은 게 단 하나라도 전자제품으로 있으면 1을 반환 -> 


SELECT
	customer_id,
    customer_name,
    customer_type
FROM customers c
WHERE EXISTS (
	SELECT 1 FROM sales s WHERE s.customer_id=c.customer_id
    AND s.category='전자제품'
);

# 있나없나를 볼 거면 웬만하면 """EXISTS"""가 효율이 넘넘넘사다.

SELECT
	c.customer_id,
    c.customer_name,
    c.customer_type
FROM customers c
WHERE
	EXISTS (
		SELECT 1 FROM sales s
		WHERE s.category='전자제품')
	AND EXISTS(
		SELECT 1 FROM sales s
		WHERE s.category='의류')
	AND EXISTS(
		SELECT 1 FROM sales s
		WHERE total_amount > 500000);
        
# """~한 적이 있는""" => """EXISTS"""