-- pg-04-index.sql
-- INDEX는 MySQL에도 있음(View 옆에 보면 있음)
-- 다만, EXPLAIN ANALYZE랑 같이 봐야 해서 pg에서 봄.

SELECT
	tablename,
	indexname,
	indexdef
FROM pg_indexes
WHERE tablename IN('large_orders', 'large_customers');

ANALYZE large_orders;
ANALYZE lerge_customers;

-- 실제 운영에서는 하면 안 되는데, 더 빠른 운영을 위해서 캐시를 날리곘음.
SELECT pg_stat_reset();

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id ='CUST-025000.';
-- "Gather  (cost=1000.00..37506.63 rows=21 width=216) (actual time=183.085..183.936 rows=0 loops=1)"
-- "  Workers Planned: 2"
-- "  Workers Launched: 2"
-- "  ->  Parallel Seq Scan on large_orders  (cost=0.00..36504.53 rows=9 width=216) (actual time=150.155..150.155 rows=0 loops=3)"
-- "        Filter: (customer_id = 'CUST-025000.'::text)"
-- "        Rows Removed by Filter: 333333"
-- "Planning Time: 98.813 ms"
-- "Execution Time: 211.409 ms"
-- INDEX 쓰고나서, 1.369 ms로 바뀜
-- INDEX 쓰고나서, seq scan(X) index scan으로 바뀜

EXPLAIN ANALYZE
SELECT amount FROM large_orders
WHERE amount BETWEEN 900000 AND 930000;
-- "Seq Scan on large_orders  (cost=0.00..46296.56 rows=198642 width=216) (actual time=0.064..207.561 rows=199657 loops=1)"
-- "  Filter: ((amount >= '800000'::numeric) AND (amount <= '1000000'::numeric))"
-- "  Rows Removed by Filter: 800343"
-- "Planning Time: 4.748 ms"
-- "Execution Time: 216.669 ms"
-- Execution Time: 260.663 ms(얘는 왜 더 걸리냐...ㄷㄷ)

-- """seq scan"""이 떴다는 건 데이터를 전부 다 봤다는 뜻.

EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region='서울' AND amount=500000 AND order_date >='2024-07-08';
-- "Gather  (cost=1000.00..39588.04 rows=1 width=216) (actual time=215.969..216.834 rows=0 loops=1)"
-- "  Workers Planned: 2"
-- "  Workers Launched: 2"
-- "  ->  Parallel Seq Scan on large_orders  (cost=0.00..38587.94 rows=1 width=216) (actual time=185.405..185.406 rows=0 loops=3)"
-- "        Filter: ((order_date >= '2024-07-08'::date) AND (region = '서울'::text) AND (amount = '500000'::numeric))"
-- "        Rows Removed by Filter: 333333"
-- "Planning Time: 5.042 ms"
-- "Execution Time: 217.157 ms"

CREATE INDEX idx_orders_region_amount ON large_orders(region, amount);
EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE region='서울'
AND amount > 800000; -- 37546 / 348.931
-- INDEX 쓰고나서, 1596 / 271.416
-- 복합 INDEX 쓰고, 743 / 737.235

-- Limit  (cost=39831.22..39842.89 rows=100 width=216) (actual time=393.320..394.995 rows=100 loops=1)
-- Execution Time: 395.969 ms

-- INDEX 추가.
CREATE INDEX idx_orders_customer_id ON large_orders(customer_id);
CREATE INDEX idx_orders_amount ON large_orders(amount);
CREATE INDEX idx_orders_region ON large_orders(region);
-- 인덱싱을 하는 법은 여전히 연구/논의 대상.
-- Execution Time: 9.860 ms

-- 복합인덱스...왜 안 될까
CREATE INDEX idx_orders_id_order_date ON large_orders(customer_id, order_date);
EXPLAIN ANALYZE
SELECT * FROM large_orders
WHERE customer_id ='CUST-25000.'	-- 644.040ms
  AND order_date >= '2024-07-01'	-- index 추가 후 : 0.552...?
ORDER BY order_date DESC;

-- 복합 index 순서의 중요도
CREATE INDEX idx_orders_region_amount ON large_orders(region, amount);
CREATE INDEX idx_orders_amount_region ON large_orders(amount, region);
-- Index 순서 가이드라인
-- (1) 고유값의 비율
SELECT
	COUNT(DISTINCT region) AS 고유지역수,
	COUNT(*) AS 전체행수,
	ROUND(COUNT(DISTINCT region)* 100/COUNT(*), 10) AS 선택도
FROM large_orders; -- 얘는 선택도가 거의 0.0007%

SELECT
	COUNT(DISTINCT amount) AS 고유금액수,
	COUNT(*) AS 전체행수
FROM large_orders; -- 얘는 지역보다 선택도가 높음(거의 99%)

SELECT
	COUNT(DISTINCT customer_id) AS 고유고객수,
	COUNT(*) AS 전체행수
FROM large_orders; -- 선택도 5%