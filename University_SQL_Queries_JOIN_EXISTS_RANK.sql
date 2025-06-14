-- Monthly Trend of Student Enrollment (JOIN Version)
SELECT MONTH(enrollment_date) AS month, COUNT(*) AS total_students
FROM students
GROUP BY MONTH(enrollment_date)
ORDER BY month;

-- Monthly Trend of Student Enrollment (EXISTS or RANK Version)
SELECT month, total_students,
RANK() OVER (ORDER BY total_students DESC) AS rank_by_enrollment
FROM (
  SELECT MONTH(enrollment_date) AS month, COUNT(*) AS total_students
  FROM students
  GROUP BY MONTH(enrollment_date)
) AS monthly;

-- Students with Pending or Failed Payments (JOIN Version)
SELECT s.name, p.payment_status, p.amount_paid
FROM students s
JOIN payments p ON s.student_id = p.student_id
WHERE p.payment_status != 'Completed';

-- Students with Pending or Failed Payments (EXISTS or RANK Version)
SELECT name
FROM students s
WHERE EXISTS (
  SELECT 1 FROM payments p 
  WHERE p.student_id = s.student_id AND p.payment_status != 'Completed'
);

-- Revenue Collection by Nationality (JOIN Version)
SELECT nationality, SUM(amount_paid) AS total_revenue
FROM students s
JOIN payments p ON s.student_id = p.student_id
WHERE p.payment_status = 'Completed'
GROUP BY nationality
ORDER BY total_revenue DESC;

-- Revenue Collection by Nationality (EXISTS or RANK Version)
SELECT nationality, total_revenue,
RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
  SELECT nationality, SUM(amount_paid) AS total_revenue
  FROM students s
  JOIN payments p ON s.student_id = p.student_id
  WHERE p.payment_status = 'Completed'
  GROUP BY nationality
) AS revenue_summary;

-- Gender Split of Students (JOIN Version)
SELECT gender, COUNT(*) AS total
FROM students
GROUP BY gender;

-- Gender Split of Students (EXISTS or RANK Version)
SELECT gender, COUNT(*) AS total,
RANK() OVER (ORDER BY COUNT(*) DESC) AS gender_rank
FROM students
GROUP BY gender;

-- Graduation Status per Student (JOIN Version)
SELECT s.student_id, s.name,
CASE WHEN g.student_id IS NULL THEN 'Not Graduated' ELSE 'Graduated' END AS status
FROM students s
LEFT JOIN graduation g ON s.student_id = g.student_id;

-- Graduation Status per Student (EXISTS or RANK Version)
SELECT s.student_id, s.name,
CASE 
  WHEN EXISTS (SELECT 1 FROM graduation g WHERE g.student_id = s.student_id) 
  THEN 'Graduated'
  ELSE 'Not Graduated'
END AS status
FROM students s;

-- Top 5 Students by Amount Paid (JOIN Version)
SELECT s.name, p.amount_paid
FROM students s
JOIN payments p ON s.student_id = p.student_id
WHERE p.payment_status = 'Completed'
ORDER BY p.amount_paid DESC
LIMIT 5;

-- Top 5 Students by Amount Paid (EXISTS or RANK Version)
-- EXISTS doesn't support ORDER BY and LIMIT together usefully, not ideal here

-- Average Payment by Honors Category (JOIN Version)
SELECT g.honors, AVG(p.amount_paid) AS avg_paid
FROM graduation g
JOIN payments p ON g.student_id = p.student_id
GROUP BY g.honors;

-- Average Payment by Honors Category (EXISTS or RANK Version)
SELECT honors, avg_paid,
RANK() OVER (ORDER BY avg_paid DESC) AS rank_avg_paid
FROM (
  SELECT g.honors, AVG(p.amount_paid) AS avg_paid
  FROM graduation g
  JOIN payments p ON g.student_id = p.student_id
  GROUP BY g.honors
) AS honor_summary;

-- Nationality with Highest Graduation Rate (JOIN Version)
SELECT s.nationality,
ROUND(COUNT(g.student_id) * 100.0 / COUNT(s.student_id), 2) AS graduation_rate
FROM students s
LEFT JOIN graduation g ON s.student_id = g.student_id
GROUP BY s.nationality;

-- Nationality with Highest Graduation Rate (EXISTS or RANK Version)
-- EXISTS cannot be used for numerator + denominator rate aggregation

-- Enrollment Count by Gender and Nationality (JOIN Version)
SELECT nationality, gender, COUNT(*) AS total
FROM students
GROUP BY nationality, gender
ORDER BY nationality;

-- Enrollment Count by Gender and Nationality (EXISTS or RANK Version)
SELECT nationality, gender, total,
RANK() OVER (PARTITION BY nationality ORDER BY total DESC) AS rank_within_nationality
FROM (
  SELECT nationality, gender, COUNT(*) AS total
  FROM students
  GROUP BY nationality, gender
) AS gender_summary;

-- Students with No Graduation But Payment Completed (JOIN Version)
SELECT s.name, p.amount_paid
FROM students s
JOIN payments p ON s.student_id = p.student_id
LEFT JOIN graduation g ON s.student_id = g.student_id
WHERE g.student_id IS NULL AND p.payment_status = 'Completed';

-- Students with No Graduation But Payment Completed (EXISTS or RANK Version)
SELECT s.name, p.amount_paid
FROM students s
JOIN payments p ON s.student_id = p.student_id
WHERE p.payment_status = 'Completed'
AND NOT EXISTS (
  SELECT 1 FROM graduation g 
  WHERE g.student_id = s.student_id
);
