# Exploratory Data Analysis (EDA) for Online Store

A Python-based notebook project that combines **data cleaning**, **feature engineering**, and **visual analysis** (using Matplotlib, Seaborn, and Plotly) to evaluate an online store's sales performance, product profitability, delivery logistics, and global geographic distribution[cite: 1].

## What it does

The notebook answers: *"Which product categories generate the most revenue and profit, how do online and offline sales channels compare, how long do deliveries take across regions, and what do our global sales maps look like?"*

It's structured across several key workflow steps:

| Step | Purpose |
|---|---|
| `Preprocessing` | Mounts Google Drive, handles missing values/duplicates, standardizes text data, corrects country alpha-2 codes (e.g., Namibia, Antarctica), and parses dates[cite: 1]. |
| `Data Merging` | Joins `events`, `products`, and `countries` datasets into a single unified analytical dataframe[cite: 1]. |
| `Feature Engineering` | Computes core financial and operational metrics: unit profit, total order profit, total income, total costs, and delivery duration in days[cite: 1]. |
| `Visualization` | Generates multi-panel summary charts for product metrics, channel splits, and interactive global Choropleth maps[cite: 1]. |

The final execution provides both quantitative summaries (total orders, total profit, online/offline percentages) and deep visual insights into the store's operations[cite: 1].

## Tables used

- `products.csv` — product reference data, including product IDs and item types[cite: 1]
- `events.csv` — transactional order logs, including order/ship dates, priorities, country codes, units sold, unit prices, and unit costs[cite: 1]
- `countries.csv` — country reference data, including country names, alpha codes, and global regions/sub-regions[cite: 1]

## Output metrics & dimensions

| Metric / Dimension | Description |
|---|---|
| `item_type` | Product category used for grouping income, costs, profit, and popularity[cite: 1] |
| `Sales Channel` | Split of revenue, expenses, profit, and order popularity between `ONLINE` and `OFFLINE` channels[cite: 1] |
| `Total_Income` | Total revenue generated (`Unit Price` × `Units Sold`)[cite: 1] |
| `Total_Cost` | Total expenses incurred (`Unit Cost` × `Units Sold`)[cite: 1] |
| `Profit From Order` | Net profit generated from orders (`Profit` × `Units Sold`)[cite: 1] |
| `Delivery Days` | Logistics metric calculated as the difference between `Ship Date` and `Order Date`[cite: 1] |
| Geographic Metrics | Country-level aggregates for price, cost, profit, and order volume visualized on global maps[cite: 1] |

## Notes / assumptions

- Built for **Google Colab** and expects source CSV files to be located in the designated Google Drive directory (`/content/drive/MyDrive/mate`)[cite: 1].
- Data cleaning enforces integrity checks, such as dropping rows with missing country codes/units sold and verifying that unit prices never fall below unit costs[cite: 1].
- Geographic mapping via `Plotly` relies on standardized country names matching built-in country name location modes[cite: 1].

## How to use

Run directly within the Jupyter Notebook environment (`Exploratory_data_analysis_for_online_store.ipynb`). Ensure all three source CSV files are placed in your Google Drive directory before executing the cells sequentially[cite: 1].
