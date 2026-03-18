# 🏦 Loan Risk Analytics — End-to-End SQL + Power BI Project

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![PowerBI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-Preprocessing-3776AB?style=flat&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Progress-orange?style=flat)

---

## 📌 Project Overview

A full-stack data analytics project simulating a real-world **loan risk management system** for a financial institution. This project covers the entire data pipeline — from raw data preprocessing to a multi-page interactive Power BI dashboard — demonstrating end-to-end skills in data engineering, SQL analysis, and business intelligence.

**Time period:** 2016 – 2025  
**Dataset size:** 20,000 loan applications  
**Tech stack:** Python · PostgreSQL · Power BI (DAX) · Git

---

## 🎯 Business Questions Answered

1. What is the loan approval rate trend over 2016–2025?
2. Which customer segments carry the highest default risk?
3. How does credit score band relate to interest rate and approval outcome?
4. What is the portfolio's monthly loan volume growth (MoM)?
5. Which income tiers and employment types have the worst bad debt ratios?
6. Who are the top 10% highest-risk applicants and what are their profiles?
7. How does debt-to-income ratio distribute across risk segments?
8. What is the running total of outstanding loan obligations over time?

---

## 🗂️ Repository Structure

```
loan-risk-analytics/
│
├── data/
│   ├── Loan_Preprocessed_Final.csv     # Cleaned dataset (56 columns, 20,000 rows)
│   └── data_dictionary.md              # Column definitions & business rules
│
├── sql/
│   ├── 01_schema_design.sql            # Star Schema DDL (fact + dimension tables)
│   ├── 02_data_import.sql              # Staging → Star Schema ETL
│   └── 03_analysis_queries.sql         # 10 advanced SQL analysis queries
│
├── powerbi/
│   └── LoanRisk_Dashboard.pbix         # 4-page interactive Power BI dashboard
│
├── docs/
│   ├── erd_diagram.png                 # Entity Relationship Diagram
│   └── dashboard_screenshots/         # Screenshots of each dashboard page
│
└── README.md
```

---

## 🏗️ Data Model — Star Schema

```
                    ┌──────────────┐
                    │   DimDate    │
                    │─────────────│
                    │ DateKey (PK) │
                    │ Year         │
                    │ Month        │
                    │ Quarter      │
                    │ DayOfWeek    │
                    └──────┬───────┘
                           │
┌──────────────┐    ┌──────▼──────────┐    ┌──────────────┐
│ DimApplicant │────│    FactLoan     │────│   DimLoan    │
│─────────────│    │─────────────────│    │─────────────│
│ ApplicantKey │    │ LoanID (PK)     │    │ LoanKey (PK) │
│ AgeGroup     │    │ DateKey (FK)    │    │ LoanPurpose  │
│ IncomeTier   │    │ ApplicantKey(FK)│    │ LoanSize     │
│ EducationLevel│   │ LoanKey (FK)    │    │ LoanDuration │
│ EmploymentStatus│ │ RiskKey (FK)    │    └──────────────┘
│ MaritalStatus │   │ LoanAmount      │
└──────────────┘   │ InterestRate    │    ┌──────────────┐
                    │ MonthlyPayment  │────│   DimRisk    │
                    │ LoanApproved    │    │─────────────│
                    │ RiskScore       │    │ RiskKey (PK) │
                    └─────────────────┘    │ RiskSegment  │
                                           │ CreditBand   │
                                           └──────────────┘
```

---

## 📊 Dashboard Overview (Power BI — 4 Pages)

| Page | Title | Key Visuals |
|------|-------|-------------|
| 1 | Executive Overview | KPI cards, Loan volume trend, Approval donut, Top purposes |
| 2 | Risk Intelligence | Risk × Credit heatmap, DTI scatter, Default rate by segment |
| 3 | Applicant Profile | Demographics breakdown, Income × Education treemap |
| 4 | Financial Deep Dive | Waterfall income flow, LTI histogram, Top 20 loans table |

---

## 💡 Key Findings

> *(To be updated after dashboard completion)*

- **Approval rate:** ~24% overall, with significant variance across credit score bands
- **Highest risk segment:** Unemployed applicants with DTI > 0.4 and prior defaults
- **Interest rate trend:** Steady increase from 2016 to 2025 correlating with base rate changes
- **Top loan purpose:** Debt Consolidation accounts for the largest approved loan volume
- **Income insight:** Lower-Middle Income tier has the highest application volume but lowest approval rate

---

## 🚀 How to Run

### Prerequisites
- PostgreSQL 14+ or SQL Server
- Power BI Desktop (free)
- Python 3.9+ (for preprocessing only)

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/loan-risk-analytics.git
cd loan-risk-analytics

# 2. Set up the database
psql -U postgres -f sql/01_schema_design.sql
psql -U postgres -f sql/02_data_import.sql

# 3. Open Power BI
# → Open powerbi/LoanRisk_Dashboard.pbix
# → Update data source connection string to your local DB
```

---

## 🛠️ Skills Demonstrated

| Area | Skills |
|------|--------|
| **SQL** | Star Schema design, Window Functions (LAG, LEAD, RANK, SUM OVER), CTEs, ROLLUP, Subqueries |
| **Data Modeling** | Fact/Dimension table design, ERD, indexing strategy |
| **Power BI** | DAX measures (YTD, MoM, CALCULATE), Drill-through, Cross-filter, Custom theme |
| **Python** | Pandas preprocessing, feature engineering, data validation |
| **Business Thinking** | KPI definition, risk segmentation, portfolio analysis |

---

## 👤 Author

**[Nguyen Trong Hieu]**  
Data Analyst | SQL · Power BI · Python  
https://github.com/Hieunguyen1892
---

*Dataset is synthetic and generated for educational/portfolio purposes only.*
