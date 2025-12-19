# Shopper Recurrence Rate – Exercise 1 (SQL)

## Overview

This document describes the approach, assumptions, and final SQL solution used to calculate the **Shopper Recurrence Rate** for Exercise 1 of the Analytics Engineer Challenge.

The solution is intentionally implemented as a **standalone SQL query in BigQuery**, without using dbt, in order to focus purely on SQL logic, keep the solution easy to review, and align closely with the problem statement, which does not require dbt for this part.

---

## Business Definition

The **Shopper Recurrence Rate** represents the percentage of shoppers who:

1. Have made a purchase with a merchant in the **most recent closed month**, and  
2. Have made **at least one other purchase with the same merchant within the previous 12 months**, including the current closed month.

Recurrence is always attributed to the **month of the current order**.

---

## Data Filtering

Only orders up to the **most recent closed month** are considered in the calculation.  
Orders from the current ongoing month are explicitly excluded to avoid partial data and ensure consistent monthly reporting.

This is implemented by filtering orders where:

```text
order_date < date_trunc(current_date(), month)
```

## Solution Approach

The solution follows a step-by-step SQL approach to identify recurrent shoppers and calculate the recurrence rate.

### 1. Order preparation
- Orders are selected from the source table and cleaned.
- The `order_date` field is truncated to month level to define the reporting period (`order_month`).
- Only orders belonging to **closed months** are included in the analysis.

### 2. Previous order identification
- A window function (`lag`) is used to identify the previous purchase date.
- The function is:
  - partitioned by `shopper_id` and `merchant_id`
  - ordered by `order_date`
- This allows retrieving the **previous purchase with the same merchant** for each order.

### 3. Recurrence logic

- An order is considered **recurrent** when the difference between `order_month` and `previous_order_month` is **less than or equal to 11 months**.
- This represents a **12-month rolling window including the current closed month**, as specified in the exercise.

The recurrence logic is implemented using `order_month` and `previous_order_month` instead of exact order dates.

This decision is intentional and aligns with the exercise definition, which specifies that recurrence must be evaluated up to the **most recent closed month**. Since the metric is calculated at **monthly granularity**, comparing months rather than individual days is sufficient and avoids unnecessary complexity.

If the recurrence logic were defined at **daily granularity**, the comparison would need to be performed using exact order dates instead of truncated months. However, given that the business requirement operates at month level, using month-based comparisons provides a clearer and more consistent interpretation of the metric.

### 4. Monthly aggregation
- Metrics are aggregated at **merchant + month** level.
- At this stage:
  - **Total shoppers** are calculated as the number of distinct shoppers per merchant and month.
  - **Recurrent shoppers** are calculated as the number of distinct shoppers who placed **at least one recurrent order** in that month.

### 5. Recurrence rate calculation
- The recurrence rate is calculated using the following formula:

```text
recurrent_shoppers / total_shoppers
```
