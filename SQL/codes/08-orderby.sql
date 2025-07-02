-- 08-orderby.sql
-- 특정 컬럼을 기준으로 정렬함
USE lecture;

SELECT * FROM students; -- 기본 정렬은 PK 기준 오름차순
-- ASC 오름차순 | DESC 내림차순(헷갈릴 수 있다.)
-- 안 헷갈리려고 DESCRIBE를 씌기도 한다.

ALTER TABLE students ADD COLUMN grade VARCHAR(1) DEFAULT 'B';
UPDATE students SET grade='B' WHERE id!=FALSE;
UPDATE students SET grade='A' WHERE id IN(1, 3, 5);
UPDATE students SET grade='C' WHERE id>=9;


SELECT * FROM students ORDER BY name; -- 정렬은 웬만하면 오름차순(ASC)
SELECT * FROM students ORDER BY name DESC;
SELECT * FROM students
WHERE age<40
ORDER BY grade
AND age DESC
LIMIT 5;

# 다중 컬럼 정렬 -> 핵심은 앞에 오는 게 우선 정렬임.
SELECT * FROM students ORDER BY
grade DESC,
age ASC;