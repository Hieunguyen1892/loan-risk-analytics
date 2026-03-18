-- ============================================================
-- FILE: 01_schema_design.sql
-- PROJECT: Loan Risk Analytics
-- DATABASE: SQL Server (SSMS)
-- DESCRIPTION: Star Schema DDL — Tao tat ca bang
-- ============================================================

-- Tao database (chay rieng lenh nay truoc)
-- CREATE DATABASE LoanRiskDW;
-- GO

USE LoanRiskDW;
GO

-- ============================================================
-- DIMENSION: DimDate
-- ============================================================
DROP TABLE IF EXISTS DimDate;

CREATE TABLE DimDate (
    DateKey         INT             NOT NULL PRIMARY KEY,  -- YYYYMMDD
    FullDate        DATE            NOT NULL,
    Year            SMALLINT        NOT NULL,
    Month           SMALLINT        NOT NULL,
    MonthName       NVARCHAR(10)    NOT NULL,
    Quarter         SMALLINT        NOT NULL,
    QuarterLabel    NVARCHAR(6)     NOT NULL,              -- 'Q1', 'Q2'...
    DayOfWeek       SMALLINT        NOT NULL,              -- 1=Mon, 7=Sun
    DayName         NVARCHAR(10)    NOT NULL,
    IsWeekend       BIT             NOT NULL,
    YearMonth       NVARCHAR(7)     NOT NULL               -- '2016-03'
);
GO

-- ============================================================
-- DIMENSION: DimApplicant
-- ============================================================
DROP TABLE IF EXISTS DimApplicant;

CREATE TABLE DimApplicant (
    ApplicantKey            INT             NOT NULL PRIMARY KEY IDENTITY(1,1),
    Age                     SMALLINT        NOT NULL,
    AgeGroup                NVARCHAR(30)    NOT NULL,
    MaritalStatus           NVARCHAR(15)    NOT NULL,
    NumberOfDependents      SMALLINT        NOT NULL,
    EducationLevel          NVARCHAR(15)    NOT NULL,
    EducationRank           SMALLINT        NOT NULL,
    EmploymentStatus        NVARCHAR(20)    NOT NULL,
    JobTenure               SMALLINT        NOT NULL,
    Experience              SMALLINT        NOT NULL,
    AnnualIncome            INT             NOT NULL,
    MonthlyIncome           DECIMAL(12,2)   NOT NULL,
    IncomeTier              NVARCHAR(30)    NOT NULL,
    HomeOwnershipStatus     NVARCHAR(15)    NOT NULL
);
GO

-- ============================================================
-- DIMENSION: DimLoan
-- ============================================================
DROP TABLE IF EXISTS DimLoan;

CREATE TABLE DimLoan (
    LoanKey             INT             NOT NULL PRIMARY KEY IDENTITY(1,1),
    LoanPurpose         NVARCHAR(30)    NOT NULL,
    LoanDuration        SMALLINT        NOT NULL,
    LoanSizeCategory    NVARCHAR(15)    NOT NULL
);
GO

-- ============================================================
-- DIMENSION: DimRisk
-- ============================================================
DROP TABLE IF EXISTS DimRisk;

CREATE TABLE DimRisk (
    RiskKey                     INT             NOT NULL PRIMARY KEY IDENTITY(1,1),
    CreditScore                 SMALLINT        NOT NULL,
    CreditScoreBand             NVARCHAR(15)    NOT NULL,
    LengthOfCreditHistory       SMALLINT        NOT NULL,
    NumberOfOpenCreditLines     SMALLINT        NOT NULL,
    NumberOfCreditInquiries     SMALLINT        NOT NULL,
    CreditCardUtilizationRate   DECIMAL(6,4)    NOT NULL,
    PaymentHistory              SMALLINT        NOT NULL,
    UtilityBillsPaymentHistory  DECIMAL(6,4)    NOT NULL,
    BankruptcyHistory           SMALLINT        NOT NULL,
    HasBankruptcy               NVARCHAR(3)     NOT NULL,
    PreviousLoanDefaults        SMALLINT        NOT NULL,
    HasPreviousDefault          NVARCHAR(3)     NOT NULL,
    RiskScore                   DECIMAL(6,2)    NOT NULL,
    RiskSegment                 NVARCHAR(20)    NOT NULL
);
GO

-- ============================================================
-- FACT TABLE: FactLoan
-- ============================================================
DROP TABLE IF EXISTS FactLoan;

CREATE TABLE FactLoan (
    LoanID                      NVARCHAR(10)    NOT NULL PRIMARY KEY,
    DateKey                     INT             NOT NULL REFERENCES DimDate(DateKey),
    ApplicantKey                INT             NOT NULL REFERENCES DimApplicant(ApplicantKey),
    LoanKey                     INT             NOT NULL REFERENCES DimLoan(LoanKey),
    RiskKey                     INT             NOT NULL REFERENCES DimRisk(RiskKey),

    -- Loan financials
    LoanAmount                  INT             NOT NULL,
    LoanToIncomeRatio           DECIMAL(8,4)    NOT NULL,
    SavingsToLoanRatio          DECIMAL(8,4)    NOT NULL,
    BaseInterestRate            DECIMAL(8,6)    NOT NULL,
    InterestRate                DECIMAL(8,6)    NOT NULL,
    InterestCost                DECIMAL(12,2)   NOT NULL,
    MonthlyLoanPayment          DECIMAL(10,2)   NOT NULL,

    -- Debt ratios
    MonthlyDebtPayments         INT             NOT NULL,
    DebtToIncomeRatio           DECIMAL(8,4)    NOT NULL,
    TotalDebtToIncomeRatio      DECIMAL(8,4)    NOT NULL,
    MonthlyDisposableIncome     DECIMAL(12,2)   NOT NULL,

    -- Assets
    SavingsAccountBalance       INT             NOT NULL,
    CheckingAccountBalance      INT             NOT NULL,
    LiquidAssets                INT             NOT NULL,
    TotalAssets                 INT             NOT NULL,
    TotalLiabilities            INT             NOT NULL,
    NetWorth                    INT             NOT NULL,
    FinancialStressIndex        DECIMAL(8,4)    NOT NULL,

    -- Outcome
    LoanApproved                SMALLINT        NOT NULL,
    ApprovalStatus              NVARCHAR(10)    NOT NULL
);
GO

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_fact_datekey    ON FactLoan(DateKey);
CREATE INDEX idx_fact_applicant  ON FactLoan(ApplicantKey);
CREATE INDEX idx_fact_loan       ON FactLoan(LoanKey);
CREATE INDEX idx_fact_risk       ON FactLoan(RiskKey);
CREATE INDEX idx_fact_approved   ON FactLoan(LoanApproved);
CREATE INDEX idx_dimdate_year    ON DimDate(Year);
CREATE INDEX idx_dimdate_ym      ON DimDate(YearMonth);
CREATE INDEX idx_risk_segment    ON DimRisk(RiskSegment);
CREATE INDEX idx_app_income      ON DimApplicant(IncomeTier);
CREATE INDEX idx_app_employ      ON DimApplicant(EmploymentStatus);
GO

-- Kiem tra tao bang thanh cong
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
