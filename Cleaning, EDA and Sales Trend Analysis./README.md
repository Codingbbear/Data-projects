
# Restaurant & Café Sales Trend Analysis

**Author:** Carl Mark Sibal  
**Tools:** Python, Pandas, NumPy, Matplotlib, Seaborn, SciPy, Statsmodels, Requests, Power BI  
**Data Sources:** [Balaji Fast Food Sales](https://www.kaggle.com/datasets/rajatsurana979/fast-food-sales-report) & [Dirty Café Sales](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training) — both from Kaggle (synthetic)

---

## Overview

A full-cycle data analysis project comparing sales patterns between two food businesses: a fast food restaurant in Mumbai, India and a café in Toronto, Canada. Using two synthetic Kaggle datasets, the project moves through data cleaning, exploratory analysis, and external data integration (weather + cultural festivities) to produce concrete, localized business recommendations for each store.

The project is structured across four phases, three of which are implemented in Python/Jupyter and one in Power BI.

---

## Project Structure

```
├── P1_Cleaning.ipynb       # Phase 1 — Data cleaning & imputation
├── P2_EDA.ipynb            # Phase 2 — Exploratory data analysis
├── P3_WnFA.ipynb           # Phase 3 — Weather & festivities analysis
└── (Phase 4)               # Power BI dashboard — see dashboard file
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
- **Item pairing potential identified** — with basket analysis ruled out due to single-item transactions, Phase 3 investigates whether items with similar revenue patterns can be grouped into combo promotions

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

*Café (Toronto):*
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

## Replication Notes

**Dependencies:**
```
pandas, numpy, matplotlib, seaborn, scipy, statsmodels, requests
```

Install with:
```bash
pip install pandas numpy matplotlib seaborn scipy statsmodels requests
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

---

## Phase 4 — Power BI Dashboard

An interactive dashboard summarizing key metrics and insights from Phases 1–3. Intended for stakeholder reporting. *(Dashboard file to be added.)*
