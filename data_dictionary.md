# 📖 Data Dictionary — Loan Risk Analytics

**Dataset:** `Loan_Preprocessed_Final.csv`  
**Rows:** 20,000 | **Columns:** 56  
**Period:** 2016-01-01 → 2025-12-31  

---

## 🗓️ Date & Time Features

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `LoanID` | STRING | Unique loan identifier, format: LN + 6-digit number | `LN000001` |
| `ApplicationDate` | DATE | Date the loan application was submitted | `2016-03-15` |
| `Year` | INT | Extracted year from ApplicationDate | `2016` |
| `Month` | INT | Extracted month (1–12) | `3` |
| `Quarter` | INT | Fiscal quarter (1–4) | `1` |
| `DayOfWeek` | STRING | Day name of the application | `Monday` |

---

## 👤 Applicant Demographics

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `Age` | INT | Applicant age in years | 18 – 80 |
| `AgeGroup` | STRING | Age bracket (derived) | Gen Z (18-24), Young Adult (25-34), Mid Adult (35-44), Senior Adult (45-54), Pre-Retirement (55+) |
| `MaritalStatus` | STRING | Marital status | Married, Single, Divorced, Widowed |
| `NumberOfDependents` | INT | Number of financial dependents | 0 – 5 |
| `EducationLevel` | STRING | Highest education attained | High School, Associate, Bachelor, Master, Doctorate |
| `EducationRank` | INT | Ordinal encoding of EducationLevel (derived) | 1 (High School) – 5 (Doctorate) |

---

## 💼 Employment & Income

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `EmploymentStatus` | STRING | Current employment type | Employed, Self-Employed, Unemployed |
| `JobTenure` | INT | Years at current job | 0 – 40 |
| `Experience` | INT | Total years of work experience | 0 – 50 |
| `AnnualIncome` | INT | Gross annual income (USD) | 15,000 – 485,341 |
| `MonthlyIncome` | FLOAT | AnnualIncome / 12 (derived) | 1,250 – 40,445 |
| `IncomeTier` | STRING | Income classification (derived) | Low Income (<30K), Lower-Middle (30K–60K), Middle (60K–100K), Upper-Middle (100K–150K), High Income (>150K) |

---

## 🏦 Credit Profile

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `CreditScore` | INT | FICO-style credit score | 300 – 850 |
| `CreditScoreBand` | STRING | Credit quality tier (derived) | Very Poor (<600), Poor (600–649), Fair (650–699), Good (700–749), Excellent (≥750) |
| `LengthOfCreditHistory` | INT | Years of credit history | 0 – 30 |
| `NumberOfOpenCreditLines` | INT | Active credit lines | 0 – 10 |
| `NumberOfCreditInquiries` | INT | Hard inquiries in last 12 months | 0 – 10 |
| `CreditCardUtilizationRate` | FLOAT | Credit card balance / credit limit | 0.00 – 1.00 |
| `PaymentHistory` | INT | Payment history score | 0 – 100 |
| `UtilityBillsPaymentHistory` | FLOAT | Proportion of on-time utility payments | 0.00 – 1.00 |
| `BankruptcyHistory` | INT | Has declared bankruptcy (binary) | 0 = No, 1 = Yes |
| `HasBankruptcy` | STRING | Human-readable BankruptcyHistory (derived) | Yes, No |
| `PreviousLoanDefaults` | INT | Has defaulted on prior loan (binary) | 0 = No, 1 = Yes |
| `HasPreviousDefault` | STRING | Human-readable PreviousLoanDefaults (derived) | Yes, No |

---

## 🏠 Assets & Liabilities

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `HomeOwnershipStatus` | STRING | Housing situation | Own, Mortgage, Rent, Other |
| `SavingsAccountBalance` | INT | Balance in savings account (USD) | 0 – 200,000 |
| `CheckingAccountBalance` | INT | Balance in checking account (USD) | 0 – 50,000 |
| `LiquidAssets` | INT | Savings + Checking (derived) | 0 – 250,000 |
| `TotalAssets` | INT | Total value of all assets (USD) | 1,000 – 1,000,000 |
| `TotalLiabilities` | INT | Total outstanding debt (USD) | 0 – 500,000 |
| `NetWorth` | INT | TotalAssets - TotalLiabilities (USD) | Can be negative |
| `FinancialStressIndex` | FLOAT | TotalLiabilities / (TotalAssets + 1) (derived) | 0.00 – 10.00+ (higher = more stressed) |

---

## 💳 Loan Details

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `LoanAmount` | INT | Requested loan amount (USD) | 1,000 – 100,000 |
| `LoanSizeCategory` | STRING | Loan size bucket (derived) | Small (<10K), Medium (10K–30K), Large (30K–60K), Very Large (>60K) |
| `LoanDuration` | INT | Loan term in months | 12, 24, 36, 48, 60, 72, 84, 96, 108, 120 |
| `LoanPurpose` | STRING | Reason for the loan | Home, Auto, Education, Debt Consolidation, Other |
| `LoanToIncomeRatio` | FLOAT | LoanAmount / AnnualIncome (derived) | 0.00 – 5.00+ (higher = riskier) |
| `SavingsToLoanRatio` | FLOAT | SavingsAccountBalance / LoanAmount (derived) | 0.00 – 10.00+ (higher = safer) |

---

## 💰 Debt & Repayment

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `MonthlyDebtPayments` | INT | Existing monthly debt obligations (USD) | 0 – 5,000 |
| `DebtToIncomeRatio` | FLOAT | MonthlyDebtPayments / MonthlyIncome | 0.00 – 1.00 |
| `TotalDebtToIncomeRatio` | FLOAT | (MonthlyDebt + MonthlyLoanPayment) / MonthlyIncome | 0.00 – 1.50 |
| `MonthlyDisposableIncome` | FLOAT | MonthlyIncome - Debt - LoanPayment (derived) | Can be negative |
| `BaseInterestRate` | FLOAT | Market base interest rate at time of application | 0.05 – 0.35 |
| `InterestRate` | FLOAT | Final interest rate offered to applicant | 0.05 – 0.45 |
| `InterestCost` | FLOAT | Total interest paid over loan life (derived) | (MonthlyPayment × Duration) - LoanAmount |
| `MonthlyLoanPayment` | FLOAT | Calculated monthly repayment amount (USD) | 50 – 5,000 |

---

## ⚠️ Risk & Outcome

| Column | Type | Description | Values / Range |
|--------|------|-------------|----------------|
| `RiskScore` | FLOAT | Composite risk score (model output) | 28.8 – 84.0 (higher = lower risk) |
| `RiskSegment` | STRING | Risk tier based on RiskScore (derived) | Very High Risk (<40), High Risk (40–54), Medium Risk (55–69), Low Risk (≥70) |
| `LoanApproved` | INT | Final approval decision (binary) | 0 = Rejected, 1 = Approved |
| `ApprovalStatus` | STRING | Human-readable LoanApproved (derived) | Approved, Rejected |

---

## 📐 Derived Feature Logic Summary

| Feature | Formula |
|---------|---------|
| `MonthlyIncome` | `AnnualIncome / 12` |
| `LiquidAssets` | `SavingsAccountBalance + CheckingAccountBalance` |
| `FinancialStressIndex` | `TotalLiabilities / (TotalAssets + 1)` |
| `LoanToIncomeRatio` | `LoanAmount / AnnualIncome` |
| `SavingsToLoanRatio` | `SavingsAccountBalance / LoanAmount` |
| `InterestCost` | `(MonthlyLoanPayment × LoanDuration) - LoanAmount` |
| `MonthlyDisposableIncome` | `MonthlyIncome - MonthlyDebtPayments - MonthlyLoanPayment` |
| `EducationRank` | High School=1, Associate=2, Bachelor=3, Master=4, Doctorate=5 |
| `RiskSegment` | Score ≥70 → Low Risk, 55–69 → Medium, 40–54 → High, <40 → Very High |
| `CreditScoreBand` | <600 → Very Poor, 600–649 → Poor, 650–699 → Fair, 700–749 → Good, ≥750 → Excellent |
| `IncomeTier` | <30K → Low, 30K–60K → Lower-Middle, 60K–100K → Middle, 100K–150K → Upper-Middle, >150K → High |
| `AgeGroup` | 18–24 → Gen Z, 25–34 → Young Adult, 35–44 → Mid Adult, 45–54 → Senior Adult, 55+ → Pre-Retirement |
| `LoanSizeCategory` | <10K → Small, 10K–30K → Medium, 30K–60K → Large, >60K → Very Large |

---

*Last updated: 2025 | For portfolio use only — dataset is synthetic.*
