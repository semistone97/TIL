# 28-any-all.sql

## 여러 값들 중 하나라도 조건을 만족하면 TRUE (OR)

#1 VIP 고객들의 최소 주문액보다 높은 주문

SELECT
	customer_id,
    product_name,
    total_amount,
    '일반고객이지만 VIP 최소보다 높음' AS 구분
FROM sales s
WHERE total_amount > ANY( # ANY 뒤에 오는 벡터값 중 하나에 한해서라도 TRUE면 TRUE다.
	# VIP들의 모든 주문금액들(vector)
	SELECT s.total_amount
	FROM sales s
	INNER JOIN customers c on s.customer_id = c.customer_id
	WHERE c.customer_type = 'VIP'
) AND customer_id NOT IN(SELECT customer_id FROM customers WHERE customer_type='VIP');

#2 어떤 지역 평균 매출액보다라도 높은 주문들
SELECT
	customer_id,
    product_name,
    total_amount,
    '최소 지역평균보다 높음' AS 구분
FROM sales s
WHERE total_amount > ANY(
	SELECT
		AVG(s.total_amount)
	FROM sales s
    GROUP BY region)
ORDER BY total_amount DESC;
    
    SELECT
		AVG(s.total_amount)
	FROM sales s
    GROUP BY region;
# MIN MAX로 쓸 수 있지만, ANY가 필요한 경우가 있음.
## 참고로 ALL은 대체가 불가임. 전부 다 TRUE여야 해서.

# ALL : 벡터 내 모든 값들이 조건을 만족해야 통과
## 모든 부서의 평균연봉보다 더 높은 연봉을 받는 사람
SELECT
	*
FROM employees
WHERE salary > ALL(
	SELECT AVG(salary)
    FROM employees
    GROUP by department_id
    );
# 참고로 위 쿼리는 실행 안 됨. 걍 예시임.

    