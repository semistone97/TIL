-- pg-07-recursive-cte.sql
-- Recursive : 재귀
-- SQL은 재귀를 잘 안 쓰는데, CTE에서만 할 수 있어서 알랴줌.
SELECT * FROM employees;

WITH RECURSIVE numbers AS (
	SELECT 1 AS num
	--
	UNION ALL
	--
	SELECT num+1
	FROM numbers
	WHERE num < 10
)
SELECT * FROM numbers;

WITH RECURSIVE org_chart AS (
	SELECT
		employee_id,
		employee_name,
		manager_id,
		department,
		1 AS level,
		employee_name::text AS 조직구조
	FROM employees
	WHERE manager_id is NULL
	UNION ALL
	SELECT
		e.employee_id,
		e.employee_name,
		e.manager_id,
		e.department,
		oc.level+1,
		(oc.조직구조 || '>>' || e.employee_name)::text
	FROM employees e
	INNER JOIN org_chart oc ON e.manager_id=oc.employee_id
)
SELECT * FROM org_chart;