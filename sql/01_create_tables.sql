-- =====================================================
-- HR Attrition Analysis | 01: Create database and tables
-- =====================================================
-- Prerequisite: import hr_clean.csv into a staging table named hr_staging
-- (SSMS: right-click HR_Analytics > Tasks > Import Flat File).
-- Note: the import wizard stores OverTime and AttritionFlag as 1/0.

CREATE DATABASE HR_Analytics;
GO
USE HR_Analytics;
GO

CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE JobRoles (
    JobRoleID INT IDENTITY(1,1) PRIMARY KEY,
    JobRoleName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Age INT, AgeGroup NVARCHAR(10), Gender NVARCHAR(10),
    MaritalStatus NVARCHAR(20), Education NVARCHAR(30),
    EducationField NVARCHAR(30), DistanceFromHome INT,
    DepartmentID INT NOT NULL REFERENCES Departments(DepartmentID),
    JobRoleID INT NOT NULL REFERENCES JobRoles(JobRoleID),
    JobLevel INT, BusinessTravel NVARCHAR(30), OverTime NVARCHAR(5),
    Attrition NVARCHAR(5), AttritionFlag INT
);

CREATE TABLE Compensation (
    EmployeeID INT PRIMARY KEY REFERENCES Employees(EmployeeID),
    MonthlyIncome INT, IncomeBand NVARCHAR(20),
    PercentSalaryHike INT, StockOptionLevel INT
);

CREATE TABLE Surveys (
    EmployeeID INT PRIMARY KEY REFERENCES Employees(EmployeeID),
    JobSatisfaction NVARCHAR(20), EnvironmentSatisfaction NVARCHAR(20),
    RelationshipSatisfaction NVARCHAR(20), JobInvolvement NVARCHAR(20),
    WorkLifeBalance NVARCHAR(20), PerformanceRating INT
);

CREATE TABLE CareerHistory (
    EmployeeID INT PRIMARY KEY REFERENCES Employees(EmployeeID),
    TotalWorkingYears INT, NumCompaniesWorked INT, TrainingTimesLastYear INT,
    YearsAtCompany INT, TenureGroup NVARCHAR(20), YearsInCurrentRole INT,
    YearsSinceLastPromotion INT, YearsWithCurrManager INT
);
GO

-- Load data from staging (order matters because of foreign keys)
INSERT INTO Departments (DepartmentName)
SELECT DISTINCT Department FROM hr_staging;

INSERT INTO JobRoles (JobRoleName)
SELECT DISTINCT JobRole FROM hr_staging;

INSERT INTO Employees
SELECT s.EmployeeNumber, s.Age, s.AgeGroup, s.Gender, s.MaritalStatus,
       s.Education, s.EducationField, s.DistanceFromHome,
       d.DepartmentID, j.JobRoleID, s.JobLevel, s.BusinessTravel,
       s.OverTime, s.Attrition, s.AttritionFlag
FROM hr_staging s
JOIN Departments d ON d.DepartmentName = s.Department
JOIN JobRoles j ON j.JobRoleName = s.JobRole;

INSERT INTO Compensation
SELECT EmployeeNumber, MonthlyIncome, IncomeBand,
       PercentSalaryHike, StockOptionLevel
FROM hr_staging;

INSERT INTO Surveys
SELECT EmployeeNumber, JobSatisfaction, EnvironmentSatisfaction,
       RelationshipSatisfaction, JobInvolvement, WorkLifeBalance, PerformanceRating
FROM hr_staging;

INSERT INTO CareerHistory
SELECT EmployeeNumber, TotalWorkingYears, NumCompaniesWorked, TrainingTimesLastYear,
       YearsAtCompany, TenureGroup, YearsInCurrentRole,
       YearsSinceLastPromotion, YearsWithCurrManager
FROM hr_staging;
GO

-- Verification (expected: 1470 rows per table, 237 leavers)
SELECT 'Employees' AS tbl, COUNT(*) AS cnt FROM Employees
UNION ALL SELECT 'Compensation', COUNT(*) FROM Compensation
UNION ALL SELECT 'Surveys', COUNT(*) FROM Surveys
UNION ALL SELECT 'CareerHistory', COUNT(*) FROM CareerHistory;

SELECT SUM(AttritionFlag) AS total_attrition FROM Employees;
