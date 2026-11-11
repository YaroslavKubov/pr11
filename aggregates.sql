-- Практична робота №11
-- Тема: Агрегація, групування та операції над множинами
-- Схема: college

-- 1. Додавання стовпця grade для зберігання оцінок.
ALTER TABLE college.enrollments
ADD COLUMN IF NOT EXISTS grade NUMERIC(5,2);

-- 2. Заповнення демонстраційних оцінок.
-- Оновлюються лише записи, у яких оцінка ще не задана.
UPDATE college.enrollments
SET grade = CASE student_id
    WHEN 101 THEN 95
    WHEN 102 THEN 88
    WHEN 103 THEN 91
    WHEN 104 THEN 76
    ELSE 80
END
WHERE grade IS NULL;


-- 3. Кількість курсів на кожному факультеті.
SELECT
    d.department_id,
    d.name AS department_name,
    COUNT(c.course_id) AS courses_count
FROM college.departments d
LEFT JOIN college.courses c
    ON d.department_id = c.department_id
GROUP BY d.department_id, d.name
ORDER BY courses_count DESC;


-- 4. Середня кількість кредитів за курсами.
SELECT
    ROUND(AVG(credits), 2) AS average_credits
FROM college.courses;


-- 5. Мінімальна та максимальна оцінки студентів.
SELECT
    MIN(grade) AS minimum_grade,
    MAX(grade) AS maximum_grade
FROM college.enrollments;


-- 6. Кількість записів на кожен курс.
-- HAVING залишає лише курси, на які записано щонайменше двох студентів.
SELECT
    course_id,
    COUNT(*) AS enrollments_count
FROM college.enrollments
GROUP BY course_id
HAVING COUNT(*) >= 2;


-- 7. Порівняння WHERE та HAVING.
-- WHERE фільтрує окремі записи до групування.
SELECT
    course_id,
    COUNT(*) AS enrollments_count
FROM college.enrollments
WHERE status = 'active'
GROUP BY course_id;


-- HAVING фільтрує вже сформовані групи.
SELECT
    course_id,
    COUNT(*) AS enrollments_count
FROM college.enrollments
GROUP BY course_id
HAVING COUNT(*) >= 2;


-- 8. Операція UNION.
-- Об'єднання курсів двох факультетів без повторень.
SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'IT'

UNION

SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'FIZ';


-- 9. Операція UNION ALL.
-- Об'єднання результатів із збереженням повторень.
SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'IT'

UNION ALL

SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'FIZ';


-- 10. Операція INTERSECT.
-- Пошук спільних ідентифікаторів курсів у двох вибірках.
SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'IT'

INTERSECT

SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'FIZ';


-- 11. Операція EXCEPT.
-- Курси першого факультету, яких немає серед курсів другого.
SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'IT'

EXCEPT

SELECT c.course_id
FROM college.courses c
JOIN college.departments d
    ON c.department_id = d.department_id
WHERE d.code = 'FIZ';


-- 12. Підрахунок кількості результатів операцій над множинами.
WITH
it_courses AS (
    SELECT c.course_id
    FROM college.courses c
    JOIN college.departments d
        ON c.department_id = d.department_id
    WHERE d.code = 'IT'
),
fiz_courses AS (
    SELECT c.course_id
    FROM college.courses c
    JOIN college.departments d
        ON c.department_id = d.department_id
    WHERE d.code = 'FIZ'
)
SELECT 'UNION' AS operation, COUNT(*) AS result_count
FROM (
    SELECT course_id FROM it_courses
    UNION
    SELECT course_id FROM fiz_courses
) result

UNION ALL

SELECT 'UNION ALL', COUNT(*)
FROM (
    SELECT course_id FROM it_courses
    UNION ALL
    SELECT course_id FROM fiz_courses
) result

UNION ALL

SELECT 'INTERSECT', COUNT(*)
FROM (
    SELECT course_id FROM it_courses
    INTERSECT
    SELECT course_id FROM fiz_courses
) result

UNION ALL

SELECT 'EXCEPT', COUNT(*)
FROM (
    SELECT course_id FROM it_courses
    EXCEPT
    SELECT course_id FROM fiz_courses
) result;


-- 13. Практичне завдання:
-- Топ-10 курсів за кількістю записаних студентів.
SELECT
    c.course_id,
    c.course_name,
    COUNT(e.student_id) AS students_count
FROM college.courses c
LEFT JOIN college.enrollments e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY students_count DESC, c.course_name
LIMIT 10;