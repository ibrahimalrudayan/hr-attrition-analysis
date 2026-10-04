-- =====================================================
-- HR Attrition Analysis | 03: Reporting view for Power BI
-- =====================================================
USE HR_Analytics;
GO

CREATE VIEW vw_HR_Full AS
SELECT e.EmployeeID, e.Age, e.AgeGroup, e.Gender, e.MaritalStatus,
       e.Education, e.EducationField, e.DistanceFromHome,
       d.DepartmentName, j.JobRoleName, e.JobLevel, e.BusinessTravel,
       CASE WHEN e.OverTime = 1 THEN 'Yes' ELSE 'No' END AS OverTime,
       CASE WHEN e.AttritionFlag = 1 THEN 'Left' ELSE 'Stayed' END AS AttritionStatus,
       e.AttritionFlag,
       c.MonthlyIncome, c.IncomeBand,
       CASE c.IncomeBand WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2
                         WHEN 'High' THEN 3 ELSE 4 END AS IncomeSort,
       c.PercentSalaryHike, c.StockOptionLevel,
       s.JobSatisfaction, s.EnvironmentSatisfaction, s.WorkLifeBalance, s.PerformanceRating,
       ch.TotalWorkingYears, ch.YearsAtCompany, ch.TenureGroup,
       CASE ch.TenureGroup WHEN '0-2 yrs' THEN 1 WHEN '3-5 yrs' THEN 2
                           WHEN '6-10 yrs' THEN 3 ELSE 4 END AS TenureSort,
       ch.YearsSinceLastPromotion
FROM Employees e
JOIN Departments d    ON d.DepartmentID = e.DepartmentID
JOIN JobRoles j       ON j.JobRoleID = e.JobRoleID
JOIN Compensation c   ON c.EmployeeID = e.EmployeeID
JOIN Surveys s        ON s.EmployeeID = e.EmployeeID
JOIN CareerHistory ch ON ch.EmployeeID = e.EmployeeID;
GO

SELECT COUNT(*) AS rows_in_view FROM vw_HR_Full;  -- expected: 1470
