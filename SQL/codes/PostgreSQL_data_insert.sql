-- 고객 테이블 (customers)
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    region VARCHAR(50),
    registration_date DATE,
    status VARCHAR(20) DEFAULT 'active'
);

-- 상품 테이블 (products)
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    supplier VARCHAR(100)
);

-- 주문 테이블 (orders) - 외래 키 제약 조건 추가
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    amount DECIMAL(12, 2),
    order_date DATE,
    status VARCHAR(20),
    region VARCHAR(50),
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 고객 데이터 삽입 (1,000명)
INSERT INTO customers (customer_id, customer_name, email, phone, region, registration_date, status)
SELECT
    'CUST-' || LPAD(generate_series::text, 6, '0') as customer_id,
    '고객' || generate_series as customer_name,
    'customer' || generate_series || '@example.com' as email,
    '010-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') || '-' || LPAD((random() * 9000 + 1000)::int::text, 4, '0') as phone,
    (ARRAY['서울', '부산', '대구', '인천', '광주', '대전', '울산'])[floor(random() * 7) + 1] as region,
    '2023-01-01'::date + (random() * 365)::int as registration_date,
    CASE WHEN random() < 0.95 THEN 'active' ELSE 'inactive' END as status
FROM generate_series(1, 1000);


-- 상품 데이터 삽입 (500개)
INSERT INTO products (product_id, product_name, category, price, stock_quantity, supplier)
SELECT
    'PROD-' || LPAD(generate_series::text, 5, '0') as product_id,
    (ARRAY['스마트폰', '노트북', '태블릿', '이어폰', '키보드', '마우스', '모니터', '스피커'])[floor(random() * 8) + 1] || ' ' || generate_series as product_name,
    (ARRAY['전자제품', '컴퓨터', '액세서리', '모바일', '음향기기'])[floor(random() * 5) + 1] as category,
    (random() * 2000000 + 50000)::decimal(10,2) as price,
    (random() * 1000 + 10)::int as stock_quantity,
    '공급업체' || (floor(random() * 20) + 1)::text as supplier
FROM generate_series(1, 500);


-- 더 현실적인 주문 분배를 위한 방법
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    amount DECIMAL(12, 2),
    order_date DATE,
    status VARCHAR(20),
    region VARCHAR(50),
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 1단계: 모든 고객이 최소 1개씩 주문하도록
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, amount, order_date, status, region, payment_method)
SELECT
    'ORDER-' || LPAD(row_number() OVER ()::text, 8, '0') as order_id,
    c.customer_id,
    (SELECT product_id FROM products ORDER BY random() LIMIT 1) as product_id,
    (floor(random() * 3) + 1)::int as quantity,
    (random() * 500000 + 50000)::decimal(10,2) as unit_price,
    0 as amount,
    '2024-01-01'::date + (random() * 210)::int as order_date,
    (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[floor(random() * 5) + 1] as status,
    c.region,
    (ARRAY['card', 'cash', 'transfer', 'mobile'])[floor(random() * 4) + 1] as payment_method
FROM customers c
WHERE c.status = 'active'
ORDER BY random();

-- 2단계: 나머지 주문들을 가중치로 분배
WITH weighted_customers AS (
    SELECT
        customer_id,
        region,
        CASE
            WHEN random() < 0.1 THEN 20  -- 10% 고객은 VIP (많은 주문)
            WHEN random() < 0.3 THEN 10  -- 20% 고객은 중간 구매력
            ELSE 3                       -- 70% 고객은 일반 구매력
        END as weight
    FROM customers
    WHERE status = 'active'
),
expanded_customers AS (
    SELECT
        customer_id,
        region
    FROM weighted_customers
    CROSS JOIN generate_series(1, weighted_customers.weight)
)
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, amount, order_date, status, region, payment_method)
SELECT
    'ORDER-' || LPAD((1000 + row_number() OVER ())::text, 8, '0') as order_id,
    ec.customer_id,
    (SELECT product_id FROM products ORDER BY random() LIMIT 1) as product_id,
    (floor(random() * 5) + 1)::int as quantity,
    (random() * 1000000 + 10000)::decimal(10,2) as unit_price,
    0 as amount,
    '2024-01-01'::date + (random() * 210)::int as order_date,
    (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[floor(random() * 5) + 1] as status,
    ec.region,
    (ARRAY['card', 'cash', 'transfer', 'mobile'])[floor(random() * 4) + 1] as payment_method
FROM (
    SELECT *, row_number() OVER (ORDER BY random()) as rn
    FROM expanded_customers
) ec
WHERE ec.rn <= 49000; -- 총 50,000개가 되도록 조정

-- 주문 금액 계산
UPDATE orders SET amount = quantity * unit_price;

-- 고객별 주문 분포 확인
SELECT 
    '고객별 주문 분포' as 분석,
    COUNT(DISTINCT customer_id) as 주문한_고객수,
    COUNT(*) as 총주문수,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT customer_id), 2) as 고객당_평균주문수,
    MIN(order_count) as 최소주문수,
    MAX(order_count) as 최대주문수
FROM (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
) customer_orders;

-- 상위 10명 고객 주문 현황
SELECT 
    customer_id,
    COUNT(*) as 주문수,
    SUM(amount) as 총구매액
FROM orders
GROUP BY customer_id
ORDER BY 주문수 DESC
LIMIT 10;

-- 고객별 주문 분포 히스토그램
SELECT 
    주문수_범위,
    COUNT(*) as 고객수
FROM (
    SELECT 
        customer_id,
        COUNT(*) as order_count,
        CASE 
            WHEN COUNT(*) = 1 THEN '1개'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN '2-5개'
            WHEN COUNT(*) BETWEEN 6 AND 10 THEN '6-10개'
            WHEN COUNT(*) BETWEEN 11 AND 50 THEN '11-50개'
            ELSE '51개 이상'
        END as 주문수_범위
    FROM orders
    GROUP BY customer_id
) customer_distribution
GROUP BY 주문수_범위
ORDER BY 주문수_범위;