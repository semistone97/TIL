SELECT version();

SHOW shared_buffers; --128MB
-- 데이터를 메모리에 캐싱한다. 라고 하는데, 램에서 공간을 이정도로 쓰고 있다는 정도.
SHOW work_mem; --4MB
SHOW maintenance_work_mem; -- 64MB
-- 선점해놓은 메모리가 이정도구나.
-- 사용하는 메모리를 바꿀 수도 있음.
-- VS code에서 이걸 쓸 수도 있음.
DROP TABLE datatyp_demo;
CREATE TABLE datatype_demo(
	-- MySQL에 있긴 한데 이름이 좀 다른 친구들
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	age INTEGER,
	salary NUMERIC(12,2),
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMP DEFAULT NOW(),
	-- 이 아래는 postgreSQL 특화타입
	tags TEXT[], -- 배열: list로 넣는 서비스 지원.
	metadata JSONB, -- JSON 타입.(JSONB는 JSON보다 빠른 binary 타입)
	ip_address INET, -- IP 주소 저장 전용(이런 식으로 특화된 타입이 많음)
	location POINT, -- 기하학 점(x, y)
	salary_range INT4RANGE -- 범위(어지간해서는 이런 걸 쓸 일은 없지만, 알려줌)
);

INSERT INTO datatype_demo (
    name, age, salary, tags, metadata, ip_address, location, salary_range
) VALUES
(
    '김철수',
    30,
    5000000.50,
    ARRAY['개발자', 'PostgreSQL', '백엔드'],        -- 배열
    '{"department": "IT", "skills": ["SQL", "Python"], "level": "senior"}'::JSONB,  -- JSONB
    '192.168.1.100'::INET,                         -- IP 주소
    POINT(37.5665, 126.9780),                      -- 서울 좌표
    '[3000000,7000000)'::INT4RANGE                 -- 연봉 범위
),
(
    '이영희',
    28,
    4500000.00,
    ARRAY['디자이너', 'UI/UX'],
    '{"department": "Design", "skills": ["Figma", "Photoshop"], "level": "middle"}'::JSONB,
    '10.0.0.1'::INET,
    POINT(35.1796, 129.0756),                      -- 부산 좌표
    '[4000000,6000000)'::INT4RANGE
);

SELECT * FROM datatype_demo;

-- 배열(tags)
SELECT
	name,
	tags[1] AS first_tag,
	'PostgreSQL'=ANY(tags) AS pg_dev
FROM datatype_demo;

-- JSONB(metadata)
SELECT 
	name,
	metadata,
	metadata->>'department' AS 부서,	-- >>는 텍스트를 뽑음
	metadata->'skills' AS 능력		-- >는 jsonb를 뽑음
FROM datatype_demo;


SELECT
	name,
	metadata->> 'department' AS 부서
FROM datatype_demo
WHERE metadata @> '{"level":"senior"}';	-- 이런 게 있다는 걸 보여주는 것.

-- 범위(range)
SELECT
	name,
	salary,
	salary_range,
	salary::INT <@ salary_range AS 연봉범위,
	UPPER(salary_range) - 	LOWER(salary_range) AS 연봉폭
FROM datatype_demo;

-- 배우는 것들이 뭔가 싶어도 나중에 쓸일이 있을 거다.

-- 좌표값(location)
SELECT
	name,
	location[0] AS 위도,
	location[1] AS 경도,
	POINT(37.5,127.005) <-> location AS 고터거리
FROM datatype_demo;