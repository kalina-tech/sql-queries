# Cumulative Revenue vs. Plan

A SQL query that tracks **running (cumulative) actual revenue against running predicted/planned revenue**, expressed as a single "% of plan achieved" figure per day.

## What it does

The query answers: *"As of each date, what percentage of our cumulative predicted revenue have we actually achieved so far?"*

It's built in stages:

| Step (CTE) | Purpose |
|---|---|
| `actual_revenue` | Daily actual revenue: sums `product.price` for all orders, grouped by session date. |
| `predict_revenue` | Daily predicted/planned revenue from `DA.revenue_predict`, grouped by date. |
| `revenues` | `FULL OUTER JOIN` of the two on `date`, so a day appears even if it only has actuals or only has a prediction. `COALESCE` picks whichever date is non-null. |

The final `SELECT` takes a **running total** of `daily_actual` and a **running total** of `daily_predict` (both via `SUM(...) OVER (ORDER BY date)`), divides one by the other, and multiplies by 100.

## Tables used

- `DA.product` — product prices
- `DA.order` — orders, linked to sessions via `ga_session_id`
- `DA.session` — session records, incl. `date`
- `DA.revenue_predict` — daily revenue predictions/plan, keyed by `date`

## Output columns

| Column | Description |
|---|---|
| `date` | Calendar date |
| `percent_done` | Cumulative actual revenue (from the start of the data through this date) divided by cumulative predicted revenue (through this date), × 100 |

## Notes / assumptions

- `percent_done` is **cumulative-to-date**, not a daily ratio — it answers "how are we tracking against plan so far overall," and will smooth out day-to-day noise (e.g. a slow single day won't crash the number if prior days were strong).
- The two CTEs `actual_revenue` and `predict_revenue` each set the *other* metric to a literal `0` before the `FULL OUTER JOIN`; `revenues` then `SUM`s them together per date. Since each source only ever contributes to one side, this is a safe way to merge two differently-sourced daily series into one row per date — not double-counting.
- Because of the `FULL OUTER JOIN`, a date with only actuals (no prediction yet) or only a prediction (no sales yet) still appears, with the missing side counted as `0` for that day — which will show up as a jump or dip in the cumulative ratio.
- If `daily_predict`'s running total is `0` for early dates (e.g. no prediction exists yet), `percent_done` will divide by zero — worth checking how the target reporting tool handles that.
- Ranking/date range is not filtered — the query returns the full history present in the underlying tables.

## How to use

Run directly against the `DA` schema. No parameters required — returns one row per date with the cumulative percent-of-plan achieved, ordered chronologically.
