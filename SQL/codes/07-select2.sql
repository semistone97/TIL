-- SELECT 컬럼 
-- FROM 테이블 
-- WHERE 조건 
-- ORDER BY 정렬기준 
-- LIMIT 개수

USE lecture;
DROP TABLE students;
CREATE TABLE students(
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20),
	age INT
);

DESC students;


INSERT INTO students(name, age) VALUES
('김 제이나', 23),
('박 스랄', 45),
('홍 굴단', 63),
('이 우서', 32),
('최 가로쉬', 39),
('안 두인', 15),
('노 루', 82),
('윤 렉사르', 52),
('박 리라', 17),
('이 일리단', 48),
('하 스스톤', 12);

SELECT * FROM students;

SELECT * FROM students WHERE name='이 우서';
SELECT * FROM students WHERE id<>10; -- <>: 여집합이란 뜻으로, 해당 조건을 제외한 모든 것들 의미.
SELECT * FROM students WHERE age>20;
SELECT * FROM students WHERE id != 10; -- != : 같지 않음
SELECT * FROM students WHERE age BETWEEN 20 AND 40; -- BETWEEN은 이상 ~ 이하로 포함시킴
SELECT * FROM students WHERE id IN(1, 3, 5, 7, 9); -- 다중지목
SELECT * FROM students WHERE age=FALSE;
SELECT * FROM students WHERE age=NULL;
-- 놀라운 사실, 한글인 상태로 영어를 복붙하면 실행이 안 됨....ㄷㄷㄷㄷㄷㄷㄷㄷㄷㄷㄷ

UPDATE students SET age=NULL WHERE id=11;

-- 문자열 패턴 """LIKE"""(%: 0~n까지가 있을 수도, 없을 수도 있다._ : 정확히 갯수만큼 글자가 있다)

SELECT * FROM students WHERE name LIKE '이%'; -- 이씨만 찾기
SELECT * FROM students WHERE name LIKE '%박%'; -- 박이 들어가는 사람
SELECT * FROM students WHERE name LIKE '% __'; -- 이름이 세 글자
SELECT * FROM students WHERE name LIKE '이 ___'; -- 이름이 네 글자며 이씨인 사SELECT * FROM students WHERE name LIKE '%랄'; -- 랄로 끝나는 사람