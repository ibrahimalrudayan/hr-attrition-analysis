-- =====================================================
-- HR Attrition Analysis | 02: Analysis queries
-- =====================================================
USE HR_Analytics;
GO

-- 1. Overall attrition rate
SELECT COUNT(*) AS total_employees,
       SUM(AttritionFlag) AS leavers,
       CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct
FROM Employees;

-- 2. Attrition and average income by department (JOINs + GROUP BY)
SELECT d.DepartmentName,
       COUNT(*) AS headcount,
       SUM(e.AttritionFlag) AS leavers,
       CAST(100.0 * SUM(e.AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct,
       ROUND(AVG(c.MonthlyIncome * 1.0), 0) AS avg_income
FROM Employees e
JOIN Departments d  ON d.DepartmentID = e.DepartmentID
JOIN Compensation c ON c.EmployeeID = e.EmployeeID
GROUP BY d.DepartmentName
ORDER BY attrition_rate_pct DESC;

-- 3. Job roles ranked by attrition risk (CTE + window function)
WITH role_stats AS (
    SELECT j.JobRoleName, d.DepartmentName,
           COUNT(*) AS headcount,
           SUM(e.AttritionFlag) AS leavers,
           CAST(100.0 * SUM(e.AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct
    FROM Employees e
    JOIN JobRoles j    ON j.JobRoleID = e.JobRoleID
    JOIN Departments d ON d.DepartmentID = e.DepartmentID
    GROUP BY j.JobRoleName, d.DepartmentName
)
SELECT *, RANK() OVER (ORDER BY attrition_rate_pct DESC) AS risk_rank
FROM role_stats
ORDER BY risk_rank;

-- 4. Effect of overtime (1 = works overtime)
SELECT OverTime,
       COUNT(*) AS headcount,
       SUM(AttritionFlag) AS leavers,
       CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct
FROM Employees
GROUP BY OverTime;

-- 5. Income of leavers vs stayers compared with the department average (window AVG)
WITH emp_income AS (
    SELECT d.DepartmentName, e.Attrition, c.MonthlyIncome,
           AVG(c.MonthlyIncome * 1.0) OVER (PARTITION BY d.DepartmentName) AS dept_avg
    FROM Employees e
    JOIN Departments d  ON d.DepartmentID = e.DepartmentID
    JOIN Compensation c ON c.EmployeeID = e.EmployeeID
)
SELECT DepartmentName, Attrition,
       ROUND(AVG(MonthlyIncome * 1.0), 0) AS avg_income,
       ROUND(AVG(dept_avg), 0) AS dept_avg_income
FROM emp_income
GROUP BY DepartmentName, Attrition
ORDER BY DepartmentName, Attrition;

-- 6. Effect of time since last promotion
WITH promo AS (
    SELECT e.AttritionFlag,
           CASE WHEN ch.YearsSinceLastPromotion = 0 THEN '1) Promoted this year'
                WHEN ch.YearsSinceLastPromotion <= 2 THEN '2) 1-2 years'
                WHEN ch.YearsSinceLastPromotion <= 5 THEN '3) 3-5 years'
                ELSE '4) 6+ years' END AS promo_gap
    FROM Employees e
    JOIN CareerHistory ch ON ch.EmployeeID = e.EmployeeID
)
SELECT promo_gap, COUNT(*) AS headcount, SUM(AttritionFlag) AS leavers,
       CAST(100.0 * SUM(AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct
FROM promo
GROUP BY promo_gap
ORDER BY promo_gap;

-- 7. Highest-risk segments (overtime + income band + tenure), minimum 20 employees
SELECT TOP 5 e.OverTime, c.IncomeBand, ch.TenureGroup,
       COUNT(*) AS headcount,
       SUM(e.AttritionFlag) AS leavers,
       CAST(100.0 * SUM(e.AttritionFlag) / COUNT(*) AS DECIMAL(5,2)) AS attrition_rate_pct
FROM Employees e
JOIN Compensation c   ON c.EmployeeID = e.EmployeeID
JOIN CareerHistory ch ON ch.EmployeeID = e.EmployeeID
GROUP BY e.OverTime, c.IncomeBand, ch.TenureGroup
HAVING COUNT(*) >= 20
ORDER BY attrition_rate_pct DESC;
