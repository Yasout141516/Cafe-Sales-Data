# Cafe Sales Data Pipeline

An end-to-end data pipeline covering ingestion, cleaning, SQL analysis, and dashboard visualization of 10,000 cafe sales transactions.

## Dataset

**Source:** [Cafe Sales — Dirty Data for Cleaning Training](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) by Ahmed Mohamed on Kaggle

The raw dataset contains 10,000 intentionally corrupted cafe sales transactions with missing values, invalid entries (`ERROR`, `UNKNOWN`), inconsistent pricing, and unparsed dates. The goal of this project is to clean, analyze, and visualize the data end to end.

## Pipeline Overview

```
Kaggle API → Python (pandas) → PostgreSQL → Power BI
```

1. Dataset ingested programmatically via the Kaggle API
2. Raw data cleaned and feature engineered using Python and pandas
3. Clean data loaded into PostgreSQL for business analysis
4. Results visualized in a Power BI dashboard

## Project Structure

```
cafe-sales-pipeline/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── data/
│   └── cafe_sales_clean.csv           ← cleaned output dataset
│
├── notebooks/
│   └── 01_data_cleaning.ipynb         ← full cleaning pipeline
│
├── sql/
│   └── business_questions.sql         ← 8 business analysis queries
│
└── dashboard/
    ├── cafe_sales_dashboard.pbix      ← Power BI dashboard file
    ├── cafe_sales_dashboard.pdf       ← exported PDF
    └── dashboard_preview.png          ← dashboard screenshot
```

## Data Cleaning Summary

The cleaning pipeline handles the following issues:

| Issue | Approach |
|---|---|
| `ERROR` and `UNKNOWN` string entries | Replaced with `NaN` |
| Missing `Quantity`, `Price Per Unit`, `Total Spent` | Mathematical imputation (`Total Spent = Quantity × Price Per Unit`) |
| Missing `Item` with unambiguous price | Reverse price-to-item mapping |
| Missing `Item` with ambiguous price ($3.00, $4.00) | Random sampling with equal probability |
| Missing `Payment Method` and `Location` | Random sampling to preserve natural distribution |
| Missing `Transaction Date` | Linear interpolation on integer-converted timestamps |
| Irrecoverable rows | Dropped after all imputation attempts |

**Result:** 9,974 clean rows retained from 10,000 — only 0.26% data loss.

## Business Questions Answered

1. Which items generate the most revenue?
2. What are the peak sales days of the week?
3. Which payment method is most popular — and does it vary by location?
4. How has monthly revenue trended across the year?
5. What is the average order value per item and per location?
6. Which items sell the highest quantity but generate below average revenue?
7. What percentage of transactions are per location per month?
8. What is the busiest hour of the day?

## Dashboard Preview

![Cafe Sales Dashboard](dashboard/dashboard_preview.png)

### Key Metrics

| Metric | Value |
|---|---|
| Total Revenue | $89,042 |
| Total Transactions | 9,974 |
| Avg Order Value | $8.93 |
| Total Items Sold | 30,170 |
| Avg Items Per Order | 3.02 |

## Tech Stack

| Tool | Purpose |
|---|---|
| Python 3 | Data cleaning and feature engineering |
| pandas | Data manipulation and imputation |
| NumPy | Numerical operations and NaN handling |
| Kaggle API | Programmatic dataset ingestion |
| PostgreSQL | Business analysis queries |
| Power BI | Interactive dashboard |
| Google Colab | Cloud notebook environment |

## How to Run

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/cafe-sales-pipeline.git
cd cafe-sales-pipeline
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Set up Kaggle credentials

Add your Kaggle credentials as Colab Secrets:
- `KAGGLE_USERNAME` → your Kaggle username
- `KAGGLE_KEY` → your Kaggle API key

### 4. Run the cleaning notebook

Open `notebooks/01_data_cleaning.ipynb` in Google Colab and run all cells. The clean CSV will be saved to `data/cafe_sales_clean.csv`.

### 5. Load into PostgreSQL

```sql
CREATE TABLE cafe_sales (
    transaction_id   VARCHAR(20) PRIMARY KEY,
    item             VARCHAR(50),
    quantity         NUMERIC(10, 2),
    price_per_unit   NUMERIC(10, 2),
    total_spent      NUMERIC(10, 2),
    payment_method   VARCHAR(50),
    location         VARCHAR(50),
    transaction_date DATE
);

COPY cafe_sales
FROM '/path/to/cafe_sales_clean.csv'
DELIMITER ','
CSV HEADER;
```

### 6. Run business queries

Open `sql/business_questions.sql` in pgAdmin or psql and run the queries.

### 7. Open the dashboard

Open `dashboard/cafe_sales_dashboard.pbix` in Power BI Desktop and connect to your PostgreSQL instance or the clean CSV.

## Notes on Imputation Decisions

- Rows with ambiguous prices ($3.00 and $4.00) had `Item` values filled via random sampling with equal 50/50 probability. This introduces synthetic data for those rows and should be treated with caution in any item-level analysis.
- Payment Method and Location were imputed via random sampling to preserve the natural distribution of each column rather than inflating any single category.
- These decisions are documented in detail inside the cleaning notebook.
