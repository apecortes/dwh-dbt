# 🧩 Analytics Engineer Challenge – Solution

This repository contains my solution to the **Analytics Engineer Challenge**, structured to clearly separate the two parts of the exercise and to demonstrate data modeling, SQL reasoning, and dbt best practices.

---

## 📁 Repository Structure

The challenge is divided into two independent parts:

```
├── part_1/
│ ├── shopper_recurrence_rate.md
│ └── shopper_recurrence_rate.sql
└── models/
│ ├── staging/
│ ├── intermediate/
│ │ ├── core/
│ │ └── risk/
│ └── marts/
│ └── risk/
├── seeds/
└── tests/
```

---

# 🧮 Part I – Shopper Recurrence Rate (SQL)

Part I of the challenge is implemented as a **standalone SQL solution**, following the exercise instructions.

All the content related to this part can be found in the `part_1` folder:

- 📄 `part_1/shopper_recurrence_rate.md`  
  → Explanation of the approach, assumptions, and logic used

- 🧾 `part_1/shopper_recurrence_rate.sql`  
  → Final SQL solution

---

# 🏗️ Part II – Loan Default Modeling (dbt)

Part II is implemented using **dbt**.

The goal of this part is to build a **detailed analytical dataset** that allows the Risk department to monitor orders that are not up to date on their payments.

---

# 🧱 High-level Architecture

The dbt project follows a layered architecture:

**staging → intermediate → mart**

Each layer has a clearly defined responsibility.

---

# 🧪 Staging Layer

- Mirrors the source tables
- Applies:
  - column renaming
  - type casting
  - light standardization
- Materialized as **views** for simplicity

> In a real production environment with large external tables (e.g. S3-backed sources), staging models would likely be materialized as tables and potentially modeled incrementally.

---

# 🔄 Intermediate Layer

The intermediate layer is split by domain:
```
intermediate/
├── core
└── risk
```


### 🔹 Core models

Core models represent **business entities**, independent of the physical data source:

- `int_orders`
- `int_product`
- `int_merchant`
- `int_shopper`

Key characteristics:
- One row per entity
- Only **data integrity tests** are applied
- Columns introduced through joins are tested to ensure join correctness

---

### 🔹 Risk models

Risk-specific transformations live under `intermediate/risk`.

- `int_orders_delayed_periods`

This model:
- Filters **only orders in default** (`is_in_default = true`)
- Expands each order into multiple rows based on delayed periods:
  - 17, 30, 60, 90 days
- Changes the grain from: 1 row per order
to **1 row per order × delayed_period**

---

### ⚙️ Delayed periods configuration

- Delayed periods are modeled using a **dbt seed**
- This avoids hardcoding business configuration in SQL
- In a production environment, this dataset could be materialized as a configuration table

---

### 🔑 Surrogate key and data integrity

Because the model introduces a **Cartesian product** (order × delayed_period):

- A **surrogate key** is generated using:
- `order_id`
- `shopper_id`
- `merchant_id`
- `product_id`
- `delayed_period`

This ensures:
- row-level uniqueness
- controlled Cartesian expansion
- safe downstream consumption

Primary key tests are configured to **fail with error severity**.

---

### 📌 Business assumptions

- Only orders in default are considered in the risk models
- It is assumed that:

**if is_in_default = true → days_unbalanced > 0**

- Therefore, delayed periods are generated based exclusively on the default flag

---

### 🧪 Custom data quality test

A custom dbt test validates that:

> For each order, the maximum generated `delayed_period` is **less than or equal to `days_unbalanced`**

This ensures that the delayed period expansion logic is always applied correctly.

- **Test name**:  
  `int_orders_delayed_periods_max_delayed_period.sql`

- **Location**:  
  `tests/intermediate/risk/int_orders_delayed_periods_max_delayed_period.sql`

---

# 📊 Mart Layer – Risk

### Final model

`defaulted_orders_delayed_period_detail`


---

### 🎯 Purpose of the mart

This model:

- Exposes a **detailed, non-aggregated dataset**
- Is intended for **monitoring and analysis**
- Is **not aggregable**
- Does **not include monetary amounts**
- Contains one row per:

order × delayed_period


The model name explicitly includes `delayed_period` to make the grain and intended usage clear.

---

### 📈 Default Ratio metric (conceptual note)

If a **Default Ratio** metric were required, it should be implemented in a **separate mart**, directly dependent on `int_orders`, where monetary amounts are available and both defaulted and non-defaulted orders are included.

The metric would be defined as:

Default Ratio = Loans in arrears debt / Total Loans amount


Where:
- Loans in arrears debt = `sum(overdue_principal + overdue_fees)`
- Total Loans amount = `sum(current_order_value)`

This calculation is intentionally **out of scope** for the risk monitoring mart.

---

## ✅ Technology Choices

- **dbt**: data modeling, testing, and documentation
- **BigQuery**: analytical warehouse, chosen for ease of setup and experimentation

> In a Redshift-based architecture, the typical flow would involve ingesting raw data into a data lake (e.g. S3), cataloging it with AWS Glue, and defining dbt sources on top of those tables.
