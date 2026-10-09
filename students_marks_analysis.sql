create database students_analysis;
use students_analysis;
rename table students_analysis_result to students_marks;
show tables;
select*
from students_marks
limit 10;
describe students_marks;

#total number of students
select count(*) as total_students
from students_marks;

#average marks for each subject
select avg('VLSI DESIGN') as vlsi_average,AVG(CCN) as ccn_average,AVG('ES&IOT') as esiot_average,AVG('ME')as me_average,AVG('RES')as res_average,AVG('CSD IV')as csd_average
from students_marks;

SELECT
    AVG(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2))) AS vlsi_average,
    AVG(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2))) AS ccn_average,
    AVG(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2))) AS esiot_average,
    AVG(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2))) AS me_average,
    AVG(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2))) AS res_average,
    AVG(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2))) AS csd_average
FROM students_marks;

#pass and fail counts for each subjects
SELECT
    'VLSI DESIGN' AS subject,
    SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) AS failed
FROM students_marks
UNION ALL
SELECT
    'CCN',
    SUM(CASE WHEN CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
    SUM(CASE WHEN CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
FROM students_marks
UNION ALL
SELECT
    'ES&IOT',
    SUM(CASE WHEN CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
    SUM(CASE WHEN CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
FROM students_marks
UNION ALL
SELECT
    'ME',
    SUM(CASE WHEN CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
    SUM(CASE WHEN CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
FROM students_marks
UNION ALL
SELECT
    'RES',
    SUM(CASE WHEN CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
    SUM(CASE WHEN CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
FROM students_marks
UNION ALL
SELECT
    'CSD IV',
    SUM(CASE WHEN CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
    SUM(CASE WHEN CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
FROM students_marks;

#top 10 students
SELECT
    `SI.NO`,
    `ROLL NO`,
    `NAME`,
    CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) AS VLSI,
    CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) AS CCN,
    CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) AS `ES&IOT`,
    CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) AS ME,
    CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) AS RES,
    CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) AS `CSD IV`,
    (
        COALESCE(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)), 0)
    ) AS total_marks
FROM students_marks
ORDER BY total_marks DESC
LIMIT 10;

#failed atleast one subject
SELECT
    `ROLL NO`,
    `NAME`,
    (
        (CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) +
        (CASE WHEN CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    ) AS failed_subjects
FROM students_marks
HAVING failed_subjects > 0
ORDER BY failed_subjects DESC;

#students ranking
WITH student_totals AS (
    SELECT
        `ROLL NO`,
        `NAME`,
        COALESCE(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)), 0)
        AS total_marks
    FROM students_marks
)
SELECT
    `ROLL NO`,
    `NAME`,
    total_marks,
    DENSE_RANK() OVER (ORDER BY total_marks DESC) AS student_rank
FROM student_totals
ORDER BY student_rank, `NAME`;

#highest score and lowest score
SELECT
    `ROLL NO`,
    `NAME`,
    (
        COALESCE(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)), 0)
    ) AS total_marks
FROM students_marks
ORDER BY total_marks DESC
LIMIT 5;

SELECT
    `ROLL NO`,
    `NAME`,
    (
        COALESCE(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)), 0) +
        COALESCE(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)), 0)
    ) AS total_marks
FROM students_marks
ORDER BY total_marks ASC
LIMIT 5;

#overall class average
SELECT
    ROUND(AVG(subject_average), 2) AS overall_class_average
FROM (
    SELECT CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) AS subject_average
    FROM students_marks
    UNION ALL
    SELECT CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2))
    FROM students_marks
    UNION ALL
    SELECT CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2))
    FROM students_marks
    UNION ALL
    SELECT CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2))
    FROM students_marks
    UNION ALL
    SELECT CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2))
    FROM students_marks
    UNION ALL
    SELECT CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2))
    FROM students_marks
) AS all_marks;

#pass percentage for each subject
SELECT
    'VLSI DESIGN' AS subject,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) IS NOT NULL THEN 1 ELSE 0 END), 0),
        2
    ) AS pass_percentage
FROM students_marks;
SELECT
    'CCN' AS subject,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(NULLIF(`CCN`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN CAST(NULLIF(`CCN`, 'OD') AS DECIMAL(10,2)) IS NOT NULL THEN 1 ELSE 0 END), 0),
        2
    ) AS pass_percentage
FROM students_marks;

#PASS PERCENTAGE FOR ALL SIX SUBJECT
SELECT
    subject,
    total_students,
    passed,
    failed,
    ROUND(100.0 * passed / NULLIF(total_students, 0), 2)
        AS pass_percentage
FROM (
    SELECT
        'VLSI DESIGN' AS subject,
        COUNT(CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2))) AS total_students,
        SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END) AS passed,
        SUM(CASE WHEN CAST(NULLIF(`VLSI DESIGN`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END) AS failed
    FROM students_marks

    UNION ALL

    SELECT
        'CCN',
        COUNT(CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2))),
        SUM(CASE WHEN CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
        SUM(CASE WHEN CAST(NULLIF(CCN, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    FROM students_marks

    UNION ALL

    SELECT
        'ES&IOT',
        COUNT(CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2))),
        SUM(CASE WHEN CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
        SUM(CASE WHEN CAST(NULLIF(`ES&IOT`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    FROM students_marks

    UNION ALL

    SELECT
        'ME',
        COUNT(CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2))),
        SUM(CASE WHEN CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
        SUM(CASE WHEN CAST(NULLIF(ME, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    FROM students_marks

    UNION ALL

    SELECT
        'RES',
        COUNT(CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2))),
        SUM(CASE WHEN CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
        SUM(CASE WHEN CAST(NULLIF(RES, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    FROM students_marks

    UNION ALL

    SELECT
        'CSD IV',
        COUNT(CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2))),
        SUM(CASE WHEN CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) >= 50 THEN 1 ELSE 0 END),
        SUM(CASE WHEN CAST(NULLIF(`CSD IV`, 'OD') AS DECIMAL(10,2)) < 50 THEN 1 ELSE 0 END)
    FROM students_marks
) AS subject_results;


