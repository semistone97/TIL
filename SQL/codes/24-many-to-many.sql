# 24-many-to-many.sql

USE lecture;
DROP TABLE students;
CREATE TABLE students (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20)
);

CREATE TABLE courses (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    classroom VARCHAR(20)
);

# 위의 students와 courses를 묶어주자.
# 중간테이블, 중계테이블 Juntion Table
CREATE TABLE students_courses (
    student_id INT,
    course_id INT,
    # 얘의 PRIMARY KEY는 어떻게 설정할까?
    PRIMARY KEY(student_id, course_id), #복합 PK
    # 재수강은요? 수업 id가 학기가 지나면서 바뀜 
    grade VARCHAR(5), #성적은 INT 줘야되지 않남
	FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

SELECT
	*
FROM students_courses;

-- 데이터 삽입
INSERT INTO students VALUES
(1, '김학생'),
(2, '이학생' ),
(3, '박학생');

INSERT INTO courses VALUES
(1, 'MySQL 데이터베이스', 'A관 101호'),
(2, 'PostgreSQL 고급', 'B관 203호'),
(3, '데이터 분석', 'A관 704호');

INSERT INTO students_courses VALUES
(1, 1, 'A'),  -- 김학생이 MySQL 수강
(1, 2,'B+'), -- 김학생이 PostgreSQL 수강
(2, 1, 'A-'), -- 이학생이 MySQL 수강
(2, 3, 'B'),  -- 이학생이 데이터분석 수강
(3, 2, 'A+'), -- 박학생이 PostgreSQL 수강
(3, 3, 'A');  -- 박학생이 데이터분석 수강

# 학생별 수강과목
SELECT
	c.name,
    GROUP_CONCAT(s.name),
    GROUP_CONCAT(sc.grade)
FROM courses c
INNER JOIN students_courses sc ON c.id=sc.course_id
INNER JOIN students s ON s.id=sc.student_id
GROUP BY c.name;

# 강의별 수강학생
SELECT
	c.id,
    c.name AS 과목명,
    c.classroom AS 강의실,
    COUNT(sc.student_id) AS 수강인원,
    GROUP_CONCAT(s.name) AS 수강학생,
    GROUP_CONCAT(sc.grade) AS 학점,
    ROUND(AVG # AVG같은 집계함수 뒤에 CASE 붙일 수 있음.
		(CASE
			WHEN sc.grade='A+' 	THEN  4.3
            WHEN sc.grade='A' 	THEN  4.0
            WHEN sc.grade='A-' 	THEN  3.7
            WHEN sc.grade='B+'	THEN  3.3
            WHEN sc.grade='B' 	THEN  3
            ELSE 0
		END)
	,2) AS 평균학점
FROM courses c
INNER JOIN students_courses sc ON c.id=sc.course_id
INNER JOIN students s ON s.id=sc.student_id
GROUP BY c.id;