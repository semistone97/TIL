-- pg-05-various-index.sql
-- index의 종류 + 언제 index를 쓰면 좋은지!

-- B-Tree 인덱스(기본)
CREATE INDEX <index_name> ON <table_name>(<col_name>)
-- 범위 검색 BETWEEN, >, <
-- 정렬 ORDER BY
-- 부분 일치 LIKE

-- Hash 인덱스
CREATE INDEX <index_name> ON <table_name> USING HASH(<col_name>)
-- 정확한 일치 검색에서 가장 뛰어남("=")
-- 범위 x, 정렬 x

-- 부분 인덱스
CREATE INDEX <index_name> oON <table_name>(<col_name>)
WHERE 조건 = 'dasfsdlgjsdlgjlsdjf'
-- 특정 조건의 데이터만 자주 검색할 때에
-- e.g. 학교에서 졸업 제외 재학 중인 학생만 인덱스를 걸어서 보는 방법.
-- e.g.2. 배달앱 배송 중인 애들만 index 조회.

-- 인덱스 안 쓰는 경우
-- 1. 함수 사용
SELECT * FROM users WHERE UPPER(name) = 'JOHN';
-- 2. 타입 변환
SELECT * FROM users WHERE age='25';		-- 원래 숫자인데 문자를 넣은 경우(보통 잘못 입력한 경우임)
-- 3. 앞쪽 와일드 카드
SELECT * FROM users WHERE LIKE='%김';	-- LIKE -> 앞쪽 와일드카드(이거 뭔말임...)
-- 부정 조건
SELECT + FROM usets WHERE age != 25;

-- 해결방법
-- 1. 함수기반 인덱싱
CREATE INDEX <name> ON users(UPPER(name));
-- 2. 타입 잘 쓰기
-- 3. 전체 텍스트 검색 인덱스 고려
-- 4. 부정조건을 범위조건으로 바꾸기
SELECT * FROM users WHERE age<25 OR age>25; -- HASH 말고 B-tree 인덱스일 때만!

-- 인덱스는 무조건 옳은가?
-- 인덱스는 검색 성능은 올리지만 / 저장공간을 먹음(새로운 데이터를 추가하기 때문) / 수정성능을 깎아머금
-- 테이블의 수정 삭제가 많으면 인덱스 설정을 안 하는 게 좋다~
-- DB를 만들어놓고, 이후 실제 쿼리 패턴을 분석해서, 인덱스를 설계해야 한다.
-- 고로 대부분의 인덱스는 실제 데이터를 기준으로 설계한다.