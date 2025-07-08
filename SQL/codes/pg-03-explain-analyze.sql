-- pg-03-explain-analyze.sql

EXPLAIN
-- EXPLAIN: 실행 계획을 보려는 것.
SELECT * FROM large_customers WHERE customer_type='VIP';
-- Seq Scan on large_customers  (cost=0.00..3746.00 rows=9953 width=160)
--  Filter: (customer_type = 'VIP'::text)

EXPLAIN ANALYZE
SELECT * FROM large_customers WHERE customer_type = 'VIP';
-- Seq(Sequence): 연속적이라는 뜻.
-- seq scan : (1) 인덱스가 없고 (2) 테이블 대부분의 행을 읽어야 하고 (3) 순차 스캔이 빠를 때.

-- VVV EXPLAIN 옵션 모음 VVV
-- 버퍼 사용량 포함()
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM large_customers WHERE loyalty_points > 8000;
-- 버퍼? 임시 메모리.

-- VERBOSE: 상세정보 포함.
EXPLAIN (ANALYZE, VERBOSE, BUFFERS) 
SELECT * FROM large_customers WHERE loyalty_points > 8000;

-- JSON 형태
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) 
SELECT * FROM large_customers WHERE loyalty_points > 8000;

-- 진단(Score is too high같은 메시지가 뜸)
EXPLAIN ANALYZE
SELECT
	c.customer_name,
	COUNT(o.order_id)
FROM large_customers c
LEFT JOIN large_orders o ON c.customer_name = o.customer_id
GROUP BY c.customer_name;

-- 분석을 했으면, 다음은 개선
