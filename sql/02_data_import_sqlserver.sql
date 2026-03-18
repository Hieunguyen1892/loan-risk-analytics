-- ============================================================
-- FILE: 02_data_import.sql
-- PROJECT: Loan Risk Analytics
-- DATABASE: SQL Server (SSMS)
-- DESCRIPTION: Import CSV -> Staging -> Star Schema
-- Chay SAU 01_schema_design.sql
-- ============================================================

USE LoanRiskDW;
GO

-- ============================================================
-- STEP 1: Tao Staging Table (map 1:1 voi CSV)
-- ============================================================
DROP TABLE IF EXISTS staging_loans;

CREATE TABLE staging_loans (
    RowNum                      INT             IDENTITY(1,1),  -- dung de join voi Dim
    LoanID                      NVARCHAR(10),
    ApplicationDate             DATE,
    Year                        SMALLINT,
    Month                       SMALLINT,
    Quarter                     SMALLINT,
    DayOfWeek                   NVARCHAR(10),
    Age                         SMALLINT,
    AgeGroup                    NVARCHAR(30),
    MaritalStatus               NVARCHAR(15),
    NumberOfDependents          SMALLINT,
    EducationLevel              NVARCHAR(15),
    EducationRank               SMALLINT,
    EmploymentStatus            NVARCHAR(20),
    JobTenure                   SMALLINT,
    AnnualIncome                INT,
    MonthlyIncome               DECIMAL(12,2),
    IncomeTier                  NVARCHAR(30),
    CreditScore                 SMALLINT,
    CreditScoreBand             NVARCHAR(15),
    LengthOfCreditHistory       SMALLINT,
    NumberOfOpenCreditLines     SMALLINT,
    NumberOfCreditInquiries     SMALLINT,
    CreditCardUtilizationRate   DECIMAL(6,4),
    PaymentHistory              SMALLINT,
    UtilityBillsPaymentHistory  DECIMAL(6,4),
    BankruptcyHistory           SMALLINT,
    HasBankruptcy               NVARCHAR(3),
    PreviousLoanDefaults        SMALLINT,
    HasPreviousDefault          NVARCHAR(3),
    HomeOwnershipStatus         NVARCHAR(15),
    SavingsAccountBalance       INT,
    CheckingAccountBalance      INT,
    LiquidAssets                INT,
    TotalAssets                 INT,
    TotalLiabilities            INT,
    NetWorth                    INT,
    FinancialStressIndex        DECIMAL(8,4),
    LoanAmount                  INT,
    LoanSizeCategory            NVARCHAR(15),
    LoanDuration                SMALLINT,
    LoanPurpose                 NVARCHAR(30),
    LoanToIncomeRatio           DECIMAL(8,4),
    SavingsToLoanRatio          DECIMAL(8,4),
    MonthlyDebtPayments         INT,
    DebtToIncomeRatio           DECIMAL(8,4),
    TotalDebtToIncomeRatio      DECIMAL(8,4),
    MonthlyDisposableIncome     DECIMAL(12,2),
    BaseInterestRate            DECIMAL(8,6),
    InterestRate                DECIMAL(8,6),
    InterestCost                DECIMAL(12,2),
    MonthlyLoanPayment          DECIMAL(10,2),
    RiskScore                   DECIMAL(6,2),
    RiskSegment                 NVARCHAR(20),
    LoanApproved                SMALLINT,
    ApprovalStatus              NVARCHAR(10),
    Experience                  SMALLINT
);
GO

-- ============================================================
-- STEP 2: Import CSV vao Staging
-- !! Sua duong dan file cho dung voi may cua ban !!
-- ============================================================
BULK INSERT staging_loans
FROM 'C:\YOUR\PATH\data\Loan_Preprocessed_Final.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,           -- bo dong header
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Kiem tra import
SELECT COUNT(*) AS staging_rows FROM staging_loans;
-- Expected: 20000
GO

-- ============================================================
-- STEP 3: Populate DimDate
-- ============================================================
INSERT INTO DimDate (
    DateKey, FullDate, Year, Month, MonthName,
    Quarter, QuarterLabel, DayOfWeek, DayName, IsWeekend, YearMonth
)
SELECT DISTINCT
    CAST(FORMAT(ApplicationDate, 'yyyyMMdd') AS INT)    AS DateKey,
    ApplicationDate                                      AS FullDate,
    YEAR(ApplicationDate)                                AS Year,
    MONTH(ApplicationDate)                               AS Month,
    DATENAME(MONTH, ApplicationDate)                     AS MonthName,
    DATEPART(QUARTER, ApplicationDate)                   AS Quarter,
    'Q' + CAST(DATEPART(QUARTER, ApplicationDate) AS NVARCHAR) AS QuarterLabel,
    DATEPART(WEEKDAY, ApplicationDate)                   AS DayOfWeek,
    DATENAME(WEEKDAY, ApplicationDate)                   AS DayName,
    CASE WHEN DATEPART(WEEKDAY, ApplicationDate) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend,
    FORMAT(ApplicationDate, 'yyyy-MM')                   AS YearMonth
FROM staging_loans;
GO

SELECT COUNT(*) AS dimdate_rows FROM DimDate;
GO

-- ============================================================
-- STEP 4: Populate DimApplicant
-- ============================================================
SET IDENTITY_INSERT DimApplicant OFF;

INSERT INTO DimApplicant (
    Age, AgeGroup, MaritalStatus, NumberOfDependents,
    EducationLevel, EducationRank, EmploymentStatus, JobTenure,
    Experience, AnnualIncome, MonthlyIncome, IncomeTier, HomeOwnershipStatus
)
SELECT
    Age, AgeGroup, MaritalStatus, NumberOfDependents,
    EducationLevel, EducationRank, EmploymentStatus, JobTenure,
    Experience, AnnualIncome, MonthlyIncome, IncomeTier, HomeOwnershipStatus
FROM staging_loans
ORDER BY RowNum;
GO

SELECT COUNT(*) AS dimapplicant_rows FROM DimApplicant;
GO

-- ============================================================
-- STEP 5: Populate DimLoan
-- ============================================================
INSERT INTO DimLoan (LoanPurpose, LoanDuration, LoanSizeCategory)
SELECT LoanPurpose, LoanDuration, LoanSizeCategory
FROM staging_loans
ORDER BY RowNum;
GO

SELECT COUNT(*) AS dimloan_rows FROM DimLoan;
GO

-- ============================================================
-- STEP 6: Populate DimRisk
-- ============================================================
INSERT INTO DimRisk (
    CreditScore, CreditScoreBand, LengthOfCreditHistory,
    NumberOfOpenCreditLines, NumberOfCreditInquiries,
    CreditCardUtilizationRate, PaymentHistory, UtilityBillsPaymentHistory,
    BankruptcyHistory, HasBankruptcy, PreviousLoanDefaults, HasPreviousDefault,
    RiskScore, RiskSegment
)
SELECT
    CreditScore, CreditScoreBand, LengthOfCreditHistory,
    NumberOfOpenCreditLines, NumberOfCreditInquiries,
    CreditCardUtilizationRate, PaymentHistory, UtilityBillsPaymentHistory,
    BankruptcyHistory, HasBankruptcy, PreviousLoanDefaults, HasPreviousDefault,
    RiskScore, RiskSegment
FROM staging_loans
ORDER BY RowNum;
GO

SELECT COUNT(*) AS dimrisk_rows FROM DimRisk;
GO

-- ============================================================
-- STEP 7: Populate FactLoan
-- Join staging voi Dim qua RowNum = IDENTITY key
-- ============================================================
INSERT INTO FactLoan (
    LoanID, DateKey, ApplicantKey, LoanKey, RiskKey,
    LoanAmount, LoanToIncomeRatio, SavingsToLoanRatio,
    BaseInterestRate, InterestRate, InterestCost, MonthlyLoanPayment,
    MonthlyDebtPayments, DebtToIncomeRatio, TotalDebtToIncomeRatio, MonthlyDisposableIncome,
    SavingsAccountBalance, CheckingAccountBalance, LiquidAssets,
    TotalAssets, TotalLiabilities, NetWorth, FinancialStressIndex,
    LoanApproved, ApprovalStatus
)
SELECT
    s.LoanID,
    CAST(FORMAT(s.ApplicationDate, 'yyyyMMdd') AS INT)  AS DateKey,
    a.ApplicantKey,
    l.LoanKey,
    r.RiskKey,

    s.LoanAmount,
    s.LoanToIncomeRatio,
    s.SavingsToLoanRatio,
    s.BaseInterestRate,
    s.InterestRate,
    s.InterestCost,
    s.MonthlyLoanPayment,

    s.MonthlyDebtPayments,
    s.DebtToIncomeRatio,
    s.TotalDebtToIncomeRatio,
    s.MonthlyDisposableIncome,

    s.SavingsAccountBalance,
    s.CheckingAccountBalance,
    s.LiquidAssets,
    s.TotalAssets,
    s.TotalLiabilities,
    s.NetWorth,
    s.FinancialStressIndex,

    s.LoanApproved,
    s.ApprovalStatus

FROM staging_loans s
JOIN DimApplicant a ON a.ApplicantKey = s.RowNum
JOIN DimLoan      l ON l.LoanKey      = s.RowNum
JOIN DimRisk      r ON r.RiskKey      = s.RowNum;
GO

SELECT COUNT(*) AS factloan_rows FROM FactLoan;
-- Expected: 20000
GO

-- ============================================================
-- STEP 8: Validation cuoi cung
-- ============================================================

-- Tong hop row count tat ca bang
SELECT 'staging_loans' AS TableName, COUNT(*) AS Rows FROM staging_loans
UNION ALL SELECT 'DimDate',      COUNT(*) FROM DimDate
UNION ALL SELECT 'DimApplicant', COUNT(*) FROM DimApplicant
UNION ALL SELECT 'DimLoan',      COUNT(*) FROM DimLoan
UNION ALL SELECT 'DimRisk',      COUNT(*) FROM DimRisk
UNION ALL SELECT 'FactLoan',     COUNT(*) FROM FactLoan;
GO

-- Kiem tra approval rate (~24%)
SELECT
    ApprovalStatus,
    COUNT(*) AS Total,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Pct
FROM FactLoan
GROUP BY ApprovalStatus;
GO

-- Kiem tra date range
SELECT MIN(FullDate) AS StartDate, MAX(FullDate) AS EndDate FROM DimDate;
-- Expected: 2016-01-01 to 2025-12-31
GO

-- Sample data check
SELECT TOP 5 * FROM FactLoan;
GO
