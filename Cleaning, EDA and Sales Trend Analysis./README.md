# Restaurant & Café Sales Trend Analysis

**Author:** Carl Mark Sibal  
**Tools:** Python, Pandas, NumPy, Matplotlib, Seaborn, SciPy, Requests, Power BI  
**Data Sources:** [Balaji Fast Food Sales](https://www.kaggle.com/datasets/rajatsurana979/fast-food-sales-report) & [Dirty Café Sales](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) — both from Kaggle (synthetic)

---

## Overview

A full-cycle data analysis project comparing sales patterns between two food businesses: a fast food restaurant in Mumbai, India and a café in Toronto, Canada. Using two synthetic Kaggle datasets, the project moves through data cleaning, exploratory analysis, external data integration (weather + cultural festivities), and interactive BI dashboard development to produce concrete, localized business recommendations for each store.

The project is structured across four phases, three implemented in Python/Jupyter and one in Power BI.

---

## Project Structure

```
├── P1_Cleaning.ipynb           # Phase 1 — Data cleaning & imputation
├── P2_EDA.ipynb                # Phase 2 — Exploratory data analysis
├── P3_WnFA.ipynb               # Phase 3 — Weather & festivities analysis
└── Restaurant_Cafe_Sales.pbix  # Phase 4 — Power BI dashboard
```

---

## Phase Summaries

### Phase 1 — Data Cleaning

The café dataset (`dirty_cafe_sales.csv`) required the most work — containing nulls, ambiguous entries (`UNKNOWN`, `ERROR`), and missing values across multiple interdependent columns. The restaurant dataset (`Balaji Fast Food Sales.csv`) was largely clean, requiring only date standardization and a transaction type fill.

**Key cleaning steps:**
- Duplicate detection on both datasets via transaction/order ID
- Multi-round conditional imputation across `Item`, `Quantity`, `Price`, and `Total_spent` using the formula `Quantity = Total_spent / Price`, recycled across columns
- `reverse_lookup` table used to recover item names from unambiguous prices; shared-price items intentionally left null to avoid misidentification
- `price_lookup` table from Kaggle documentation used in a third imputation pass to recover additional values
- Rows with unresolvable `Item` nulls quarantined to `removed_records.csv` to preserve data integrity
- Flag column added to mark rows with missing dates

**Null recovery summary (Café dataset):**

| Column | Before | After (pre-quarantine) | Recovered |
|---|---|---|---|
| Item | 636\* | 501 | 135 |
| Quantity | 479 | 23 | 456 |
| Price | 533 | 6 | 527 |
| Total_spent | 502 | 23 | 479 |
| Payment Method | 2,579 | 2,579 | — (not derivable) |
| Order Method | 3,265 | 3,265 | — (not derivable) |
| Date | 460 | 460 | — (not derivable) |

*\*636 = 333 genuine nulls + 'ERROR'/'UNKNOWN' entries standardized to NaN*

---

### Phase 2 — Exploratory Data Analysis

Explores revenue trends, item performance, and seasonal patterns across both businesses independently (direct monetary comparison avoided due to INR vs CAD currency difference).

**Key findings:**
- **Revenue is price-driven, not demand-driven** — item quantities are roughly equal across all menu items in both stores, meaning price point is the primary differentiator in revenue performance
- **Both businesses share a mid-year dip (Q2–Q3)** — suggesting external factors such as weather or seasonality influence customer behaviour regardless of geography
- **Cultural festivities matter** — the restaurant's Q4 spike aligns closely with the Diwali period, suggesting foot traffic is culturally driven in the Indian market

**Visualizations produced:** Monthly revenue trends, revenue and volume per item, quarterly performance breakdown.

---

### Phase 3 — Weather & Festivities Analysis

Builds on Phase 2 by integrating real-world weather data via the [Open-Meteo Archive API](https://open-meteo.com/) using proxy cities (Toronto for café, Mumbai for restaurant) and analyzing the effect of Diwali on restaurant revenue.

**Scope & limitations:**
- Weather data is at daily resolution — intraday variation not captured
- 435 café transactions with missing dates excluded from weather analysis only
- Diwali analysis conducted for restaurant only — café menu does not align with the festivity
- `rain_sum` and `snowfall_sum` excluded (Open-Meteo premium tier); WMO weather codes and `precipitation_sum` used instead

**Key findings:**

*Restaurant (Mumbai):*
- Temperature shows no statistically significant correlation with daily revenue (r = -0.041, p = 0.449)
- Moderate rain days show the highest median daily revenue — customers are not deterred by weather
- **Pre-Diwali weeks outperform Diwali itself** — customers frontload spending in the lead-up rather than dining out during the festival, contradicting the original hypothesis
- **Item pairing potential identified** — with basket analysis ruled out due to single-item transactions.
*Cafe (Toronto):*
- Temperature shows no statistically significant correlation with daily revenue (r = -0.025, p = 0.631)
- Revenue is consistent across all weather conditions including snow — indicative of a loyal, repeat customer base
- Day-of-week analysis confirms no single day significantly outperforms others (range: 209–227 CAD median)

**Item pairing recommendations** based on similar monthly revenue patterns:

| Store | Bundle | Items |
|---|---|---|
| Restaurant | Bundle 1 | Frankie + Vadapav + Sugarcane Juice |
| Restaurant | Bundle 2 | Aalopuri + Panipuri + Cold Coffee |
| Café | Bundle 1 | Salad + Cookie + Coffee |
| Café | Bundle 2 | Sandwich + Tea |

**Business recommendations:** Targeted pre-Diwali marketing campaigns for the restaurant; loyalty programs and new menu exploration for the café given its stable customer base.

---

### Phase 4 — Power BI Dashboard

Translates all prior analysis into an interactive Power BI dashboard designed for non-technical business stakeholders. The dashboard spans three pages and covers revenue performance, weather impact, and time-based trends across both stores. All monetary comparisons between Balaji (INR) and the Toronto Café (CAD) are kept independent throughout — no cross-currency aggregation is performed at any point.

#### Data Model

Four CSVs exported from Phase 3 were loaded into Power BI:

| Table | Description |
|---|---|
| `balaji_sales` | Transaction-level data for Balaji Fast Food |
| `balaji_daily` | Daily aggregates including weather data for Balaji |
| `cafe_sales` | Transaction-level data for Toronto Café |
| `cafe_daily` | Daily aggregates including weather data for Toronto Café |

Two One-to-Many relationships were manually created in Model View:

- `balaji_daily[date]` → `balaji_sales[date]`
- `cafe_daily[date]` → `cafe_sales[date]`

#### DAX Measures

```DAX
Total Revenue Balaji = SUM(balaji_sales[Total_amount])
Avg Order Value Balaji = AVERAGE(balaji_sales[Total_amount])
Total Transactions Balaji = COUNTROWS(balaji_sales)

Total Revenue Cafe = SUM(cafe_sales[Price])
Avg Order Value Cafe = AVERAGE(cafe_sales[Price])
Total Transactions Cafe = COUNTROWS(cafe_sales)

Avg Daily Revenue Balaji = AVERAGE(balaji_daily[Daily_revenue])
Avg Daily Revenue Cafe = AVERAGE(cafe_daily[Daily_revenue])
```

Calculated column added to `balaji_daily` for day-of-week analysis:

```DAX
day_of_week = FORMAT(balaji_daily[date], "dddd")
```

#### Dashboard Pages

**Page 1 — Revenue Overview**  
High-level performance snapshot for both stores. Six KPI cards display Total Revenue, Average Order Value, and Total Transactions for each store side by side. Time series charts show revenue trends across the full date range.

**Page 2 — Time Trends**  
Examines revenue behaviour across time dimensions — by month, day of week, and week number — for both stores independently.

**Page 3 — Weather & Revenue**  
Tests whether weather drives revenue for either store. Scatter charts plot daily temperature against daily revenue; column charts show average revenue by weather condition. A key finding callout anchors the page conclusion for stakeholders.

#### Key Findings

- **Weather is not a meaningful revenue driver for either store.** Balaji revenue shows no directional relationship with temperature across a 25–40°C range. Toronto Café revenue remains flat across all conditions from -20°C to 30°C, including snow. Average revenue by weather condition sits within a narrow band for both stores.
- **Pre-Diwali weeks outperform Diwali itself for Balaji.** Revenue peaks in the weeks leading up to Diwali, not on the festival date — suggesting customers frontload festive spending in advance. This has direct implications for promotional timing and inventory planning.
- **Toronto Café revenue is flat and consistent year-round.** No seasonal pattern, weather sensitivity, or weekly cycle drives meaningful variation. Performance stability points to a loyal, habitual customer base rather than an event or season-driven one.

---

## Replication Notes

**Dependencies:**
```
pandas, numpy, matplotlib, seaborn, scipy, requests
```

Install with:
```bash
pip install pandas numpy matplotlib seaborn scipy requests
```

**Weather data:** This project uses the Open-Meteo Archive API (free, no key required). The historical endpoint is periodically unavailable — check [https://status.open-meteo.com/](https://status.open-meteo.com/) before running Phase 3. If unavailable, [Meteostat](https://meteostat.net/) is a reliable free alternative covering the same date ranges and locations.

**File paths:** All `pd.read_csv()` paths in the notebooks use local absolute paths and will need to be updated to match your directory structure before running.

---

## Dataset Details

| Dataset | Source | Currency | Date Range | Rows |
|---|---|---|---|---|
| Balaji Fast Food Sales | Kaggle | INR | Apr 2022 – Mar 2023 | ~1,000 |
| Dirty Café Sales | Kaggle | CAD | 2023 | ~10,000 |

Both datasets are synthetic. Toronto and Mumbai were selected as proxy cities to provide real-world weather and cultural context.
