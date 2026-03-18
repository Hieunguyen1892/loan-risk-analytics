-- ============================================================
-- FILE: 02_data_import.sql
-- PROJECT: Loan Risk Analytics
-- DESCRIPTION: Load CSV → Staging → Star Schema (ETL)
-- Run AFTER 01_schema_design.sql
-- ============================================================

SET search_path TO loan_dw;


-- ============================================================
-- STEP 1: Create staging table (mirrors CSV exactly)
-- ============================================================
DROP TABLE IF EXISTS staging_loans;

CREATE TABLE staging_loans (
    LoanID                      VARCHAR(10),
    ApplicationDate             DATE,
    Year                        SMALLINT,
    Month                       SMALLINT,
    Quarter                     SMALLINT,
    DayOfWeek                   VARCHAR(10),
    Age                         SMALLINT,
    AgeGroup                    VARCHAR(30),
    MaritalStatus               VARCHAR(15),
    NumberOfDependents          SMALLINT,
    EducationLevel              VARCHAR(15),
    EducationRank               SMALLINT,
    EmploymentStatus            VARCHAR(20),
    JobTenure                   SMALLINT,
    AnnualIncome                INT,
    MonthlyIncome               NUMERIC(12,2),
    IncomeTier                  VARCHAR(30),
    CreditScore                 SMALLINT,
    CreditScoreBand             VARCHAR(15),
    LengthOfCreditHistory       SMALLINT,
    NumberOfOpenCreditLines     SMALLINT,
    NumberOfCreditInquiries     SMALLINT,
    CreditCardUtilizationRate   NUMERIC(6,4),
    PaymentHistory              SMALLINT,
    UtilityBillsPaymentHistory  NUMERIC(6,4),
    BankruptcyHistory           SMALLINT,
    HasBankruptcy               VARCHAR(3),
    PreviousLoanDefaults        SMALLINT,
    HasPreviousDefault          VARCHAR(3),
    HomeOwnershipStatus         VARCHAR(15),
    SavingsAccountBalance       INT,
    CheckingAccountBalance      INT,
    LiquidAssets                INT,
    TotalAssets                 INT,
    TotalLiabilities            INT,
    NetWorth                    INT,
    FinancialStressIndex        NUMERIC(8,4),
    LoanAmount                  INT,
    LoanSizeCategory            VARCHAR(15),
    LoanDuration                SMALLINT,
    LoanPurpose                 VARCHAR(30),
    LoanToIncomeRatio           NUMERIC(8,4),
    SavingsToLoanRatio          NUMERIC(8,4),
    MonthlyDebtPayments         INT,
    DebtToIncomeRatio           NUMERIC(8,4),
    TotalDebtToIncomeRatio      NUMERIC(8,4),
    MonthlyDisposableIncome     NUMERIC(12,2),
    BaseInterestRate            NUMERIC(8,6),
    InterestRate                NUMERIC(8,6),
    InterestCost                NUMERIC(12,2),
    MonthlyLoanPayment          NUMERIC(10,2),
    RiskScore                   NUMERIC(6,2),
    RiskSegment                 VARCHAR(20),
    LoanApproved                SMALLINT,
    ApprovalStatus              VARCHAR(10),
    Experience                  SMALLINT
);

-- ============================================================
-- STEP 2: Import CSV into staging
-- NOTE: Update the file path to match your local setup
-- ============================================================

COPY staging_loans
FROM '/YOUR/PATH/data/Loan_Preprocessed_Final.csv'
DELIMITER ','
CSV HEADER;

-- Verify import
SELECT COUNT(*) AS staging_rows FROM staging_loans;
-- Expected: 20000


-- ============================================================
-- STEP 3: Populate DimDate
-- Generate one row per unique date in the dataset
-- ============================================================
INSERT INTO DimDate (
    DateKey, FullDate, Year, Month, MonthName,
    Quarter, QuarterLabel, DayOfWeek, DayName, IsWeekend, YearMonth
)
SELECT DISTINCT
    TO_CHAR(ApplicationDate, 'YYYYMMDD')::INT          AS DateKey,
    ApplicationDate                                     AS FullDate,
    EXTRACT(YEAR  FROM ApplicationDate)::SMALLINT       AS Year,
    EXTRACT(MONTH FROM ApplicationDate)::SMALLINT       AS Month,
    TO_CHAR(ApplicationDate, 'Month')                   AS MonthName,
    EXTRACT(QUARTER FROM ApplicationDate)::SMALLINT     AS Quarter,
    'Q' || EXTRACT(QUARTER FROM ApplicationDate)::TEXT  AS QuarterLabel,
    EXTRACT(ISODOW FROM ApplicationDate)::SMALLINT      AS DayOfWeek,
    TO_CHAR(ApplicationDate, 'Day')                     AS DayName,
    EXTRACT(ISODOW FROM ApplicationDate) IN (6,7)       AS IsWeekend,
    TO_CHAR(ApplicationDate, 'YYYY-MM')                 AS YearMonth
FROM staging_loans
ORDER BY ApplicationDate;

SELECT COUNT(*) AS dimdate_rows FROM DimDate;


-- ============================================================
-- STEP 4: Populate DimApplicant
-- ============================================================
INSERT INTO DimApplicant (
    Age, AgeGroup, MaritalStatus, NumberOfDependents,
    EducationLevel, EducationRank, EmploymentStatus, JobTenure,
    Experience, AnnualIncome, MonthlyIncome, IncomeTier, HomeOwnershipStatus
)
SELECT
    Age, AgeGroup, MaritalStatus, NumberOfDependents,
    EducationLevel, EducationRank, EmploymentStatus, JobTenure,
    Experience, AnnualIncome, MonthlyIncome, IncomeTier, HomeOwnershipStatus
FROM staging_loans;

SELECT COUNT(*) AS dimapplicant_rows FROM DimApplicant;


-- ============================================================
-- STEP 5: Populate DimLoan
-- ============================================================
INSERT INTO DimLoan (LoanPurpose, LoanDuration, LoanSizeCategory)
SELECT LoanPurpose, LoanDuration, LoanSizeCategory
FROM staging_loans;

SELECT COUNT(*) AS dimloan_rows FROM DimLoan;


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
FROM staging_loans;

SELECT COUNT(*) AS dimrisk_rows FROM DimRisk;


-- ============================================================
-- STEP 7: Populate FactLoan (join staging with all Dims)
-- Each staging row maps to one row per Dim via ROW_NUMBER()
-- ============================================================

-- Add a row number to staging for 1:1 joins with Dim inserts
ALTER TABLE staging_loans ADD COLUMN IF NOT EXISTS row_num SERIAL;

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
    TO_CHAR(s.ApplicationDate, 'YYYYMMDD')::INT     AS DateKey,
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
JOIN DimApplicant a ON a.ApplicantKey = s.row_num
JOIN DimLoan      l ON l.LoanKey      = s.row_num
JOIN DimRisk      r ON r.RiskKey      = s.row_num;

SELECT COUNT(*) AS factloan_rows FROM FactLoan;
-- Expected: 20000


-- ============================================================
-- STEP 8: Final validation
-- ============================================================

-- Row count summary
SELECT 'staging_loans'  AS table_name, COUNT(*) AS rows FROM staging_loans
UNION ALL SELECT 'DimDate',       COUNT(*) FROM DimDate
UNION ALL SELECT 'DimApplicant',  COUNT(*) FROM DimApplicant
UNION ALL SELECT 'DimLoan',       COUNT(*) FROM DimLoan
UNION ALL SELECT 'DimRisk',       COUNT(*) FROM DimRisk
UNION ALL SELECT 'FactLoan',      COUNT(*) FROM FactLoan;

-- Approval rate sanity check (~24% expected)
SELECT
    ApprovalStatus,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM FactLoan
GROUP BY ApprovalStatus;

-- Date range check
SELECT MIN(FullDate), MAX(FullDate) FROM DimDate;
-- Expected: 2016-01-01 to 2025-12-31

-- Clean up staging (optional — comment out if you want to keep it)
-- DROP TABLE IF EXISTS staging_loans;
