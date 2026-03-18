-- ============================================================
-- FILE: 01_schema_design.sql
-- PROJECT: Loan Risk Analytics
-- DESCRIPTION: Star Schema DDL — Create all tables
-- DATABASE: PostgreSQL 14+
-- ============================================================

-- Create dedicated schema
CREATE SCHEMA IF NOT EXISTS loan_dw;
SET search_path TO loan_dw;


-- ============================================================
-- DIMENSION: DimDate
-- ============================================================
DROP TABLE IF EXISTS DimDate CASCADE;

CREATE TABLE DimDate (
    DateKey         INT             PRIMARY KEY,   -- Format: YYYYMMDD e.g. 20160315
    FullDate        DATE            NOT NULL,
    Year            SMALLINT        NOT NULL,
    Month           SMALLINT        NOT NULL,
    MonthName       VARCHAR(10)     NOT NULL,
    Quarter         SMALLINT        NOT NULL,
    QuarterLabel    VARCHAR(6)      NOT NULL,      -- e.g. 'Q1', 'Q2'
    DayOfWeek       SMALLINT        NOT NULL,      -- 1=Monday, 7=Sunday
    DayName         VARCHAR(10)     NOT NULL,
    IsWeekend       BOOLEAN         NOT NULL,
    YearMonth       VARCHAR(7)      NOT NULL       -- e.g. '2016-03'
);

COMMENT ON TABLE DimDate IS 'Date dimension — one row per calendar day (2016–2025)';


-- ============================================================
-- DIMENSION: DimApplicant
-- ============================================================
DROP TABLE IF EXISTS DimApplicant CASCADE;

CREATE TABLE DimApplicant (
    ApplicantKey            SERIAL          PRIMARY KEY,
    Age                     SMALLINT        NOT NULL,
    AgeGroup                VARCHAR(30)     NOT NULL,
    MaritalStatus           VARCHAR(15)     NOT NULL,
    NumberOfDependents      SMALLINT        NOT NULL,
    EducationLevel          VARCHAR(15)     NOT NULL,
    EducationRank           SMALLINT        NOT NULL,
    EmploymentStatus        VARCHAR(20)     NOT NULL,
    JobTenure               SMALLINT        NOT NULL,
    Experience              SMALLINT        NOT NULL,
    AnnualIncome            INT             NOT NULL,
    MonthlyIncome           NUMERIC(12,2)   NOT NULL,
    IncomeTier              VARCHAR(30)     NOT NULL,
    HomeOwnershipStatus     VARCHAR(15)     NOT NULL
);

COMMENT ON TABLE DimApplicant IS 'Applicant profile dimension — demographics, employment, income';


-- ============================================================
-- DIMENSION: DimLoan
-- ============================================================
DROP TABLE IF EXISTS DimLoan CASCADE;

CREATE TABLE DimLoan (
    LoanKey             SERIAL          PRIMARY KEY,
    LoanPurpose         VARCHAR(30)     NOT NULL,
    LoanDuration        SMALLINT        NOT NULL,    -- in months
    LoanSizeCategory    VARCHAR(15)     NOT NULL
);

COMMENT ON TABLE DimLoan IS 'Loan characteristics dimension — purpose, term, size';


-- ============================================================
-- DIMENSION: DimRisk
-- ============================================================
DROP TABLE IF EXISTS DimRisk CASCADE;

CREATE TABLE DimRisk (
    RiskKey                 SERIAL          PRIMARY KEY,
    CreditScore             SMALLINT        NOT NULL,
    CreditScoreBand         VARCHAR(15)     NOT NULL,
    LengthOfCreditHistory   SMALLINT        NOT NULL,
    NumberOfOpenCreditLines SMALLINT        NOT NULL,
    NumberOfCreditInquiries SMALLINT        NOT NULL,
    CreditCardUtilizationRate NUMERIC(6,4)  NOT NULL,
    PaymentHistory          SMALLINT        NOT NULL,
    UtilityBillsPaymentHistory NUMERIC(6,4) NOT NULL,
    BankruptcyHistory       SMALLINT        NOT NULL,   -- 0 or 1
    HasBankruptcy           VARCHAR(3)      NOT NULL,   -- 'Yes' / 'No'
    PreviousLoanDefaults    SMALLINT        NOT NULL,   -- 0 or 1
    HasPreviousDefault      VARCHAR(3)      NOT NULL,   -- 'Yes' / 'No'
    RiskScore               NUMERIC(6,2)    NOT NULL,
    RiskSegment             VARCHAR(20)     NOT NULL
);

COMMENT ON TABLE DimRisk IS 'Credit risk profile dimension — scores, flags, segment';


-- ============================================================
-- FACT TABLE: FactLoan
-- ============================================================
DROP TABLE IF EXISTS FactLoan CASCADE;

CREATE TABLE FactLoan (
    LoanID                      VARCHAR(10)     PRIMARY KEY,
    DateKey                     INT             NOT NULL REFERENCES DimDate(DateKey),
    ApplicantKey                INT             NOT NULL REFERENCES DimApplicant(ApplicantKey),
    LoanKey                     INT             NOT NULL REFERENCES DimLoan(LoanKey),
    RiskKey                     INT             NOT NULL REFERENCES DimRisk(RiskKey),

    -- Loan financials
    LoanAmount                  INT             NOT NULL,
    LoanToIncomeRatio           NUMERIC(8,4)    NOT NULL,
    SavingsToLoanRatio          NUMERIC(8,4)    NOT NULL,
    BaseInterestRate            NUMERIC(8,6)    NOT NULL,
    InterestRate                NUMERIC(8,6)    NOT NULL,
    InterestCost                NUMERIC(12,2)   NOT NULL,
    MonthlyLoanPayment          NUMERIC(10,2)   NOT NULL,

    -- Debt ratios
    MonthlyDebtPayments         INT             NOT NULL,
    DebtToIncomeRatio           NUMERIC(8,4)    NOT NULL,
    TotalDebtToIncomeRatio      NUMERIC(8,4)    NOT NULL,
    MonthlyDisposableIncome     NUMERIC(12,2)   NOT NULL,

    -- Assets
    SavingsAccountBalance       INT             NOT NULL,
    CheckingAccountBalance      INT             NOT NULL,
    LiquidAssets                INT             NOT NULL,
    TotalAssets                 INT             NOT NULL,
    TotalLiabilities            INT             NOT NULL,
    NetWorth                    INT             NOT NULL,
    FinancialStressIndex        NUMERIC(8,4)    NOT NULL,

    -- Outcome
    LoanApproved                SMALLINT        NOT NULL,   -- 0 or 1
    ApprovalStatus              VARCHAR(10)     NOT NULL    -- 'Approved' / 'Rejected'
);

COMMENT ON TABLE FactLoan IS 'Fact table — one row per loan application with all measurable metrics';


-- ============================================================
-- INDEXES — optimise common JOIN & filter patterns
-- ============================================================
CREATE INDEX idx_fact_datekey      ON FactLoan(DateKey);
CREATE INDEX idx_fact_applicant    ON FactLoan(ApplicantKey);
CREATE INDEX idx_fact_loan         ON FactLoan(LoanKey);
CREATE INDEX idx_fact_risk         ON FactLoan(RiskKey);
CREATE INDEX idx_fact_approved     ON FactLoan(LoanApproved);
CREATE INDEX idx_fact_loanamount   ON FactLoan(LoanAmount);

CREATE INDEX idx_dimdate_year      ON DimDate(Year);
CREATE INDEX idx_dimdate_yearmonth ON DimDate(YearMonth);
CREATE INDEX idx_dimrisk_segment   ON DimRisk(RiskSegment);
CREATE INDEX idx_dimapp_income     ON DimApplicant(IncomeTier);
CREATE INDEX idx_dimapp_employ     ON DimApplicant(EmploymentStatus);


-- ============================================================
-- VERIFICATION QUERIES — run after loading data
-- ============================================================

-- Check row counts
-- SELECT 'DimDate'      AS tbl, COUNT(*) AS rows FROM DimDate
-- UNION ALL SELECT 'DimApplicant', COUNT(*) FROM DimApplicant
-- UNION ALL SELECT 'DimLoan',      COUNT(*) FROM DimLoan
-- UNION ALL SELECT 'DimRisk',      COUNT(*) FROM DimRisk
-- UNION ALL SELECT 'FactLoan',     COUNT(*) FROM FactLoan;

-- Verify no orphan foreign keys
-- SELECT COUNT(*) AS orphan_dates     FROM FactLoan f LEFT JOIN DimDate d ON f.DateKey = d.DateKey WHERE d.DateKey IS NULL;
-- SELECT COUNT(*) AS orphan_applicant FROM FactLoan f LEFT JOIN DimApplicant a ON f.ApplicantKey = a.ApplicantKey WHERE a.ApplicantKey IS NULL;
