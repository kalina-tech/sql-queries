# Top-Country Email Performance

A SQL query that builds a detailed, day-by-country breakdown of account and email-campaign activity, then narrows the result to the **top 10 countries** — either by total account volume or by total emails sent.

## What it does

The query answers: *"For our biggest markets by accounts or by email volume, how do account counts and email engagement (sent / opened / visited) break down by day, send interval, verification status, and subscription status?"*

It's built in stages:

| Step (CTE) | Purpose |
|---|---|
| `params` | Base join: one row per account/session, with `date`, `country`, `send_interval`, `is_verified`, `is_unsubscribed`. |
| `account_metrics` | Distinct account counts per `date, country, send_interval, is_verified, is_unsubscribed`. Email columns set to `0` as placeholders so the schema matches `email_metrics`. |
| `email_metrics` | Email activity (sent / opened / visited) per the same dimensions, with `date` reconstructed as `session date + sent_date offset`. `account_cnt` set to `0` as a placeholder. |
| `combined_base_metrics` | `UNION ALL` of `account_metrics` and `email_metrics` — stacks the two metric types into one table. |
| `aggregated_base_metrics` | `SUM`s the union back down to one row per dimension combo, merging the account row and the email row for each group. |
| `with_country_totals` | Adds `total_country_account_cnt` and `total_country_sent_cnt` — country-wide totals via `SUM(...) OVER (PARTITION BY country)`. |
| `with_ranks` | Ranks countries with `DENSE_RANK()` on those two totals (highest first). |

The final `SELECT` keeps every detail row belonging to a country that is **top 10 by account count OR top 10 by sent messages**.

## Tables used

- `DA.session_params` — session dimensions, incl. `country`
- `DA.session` — session records, incl. `date`
- `DA.account_session` — bridge table linking accounts to sessions
- `DA.account` — accounts, incl. `send_interval`, `is_verified`, `is_unsubscribed`
- `DA.email_sent` — email sends, incl. `sent_date` offset and `id_message`
- `DA.email_open` — email opens, keyed by `id_message`
- `DA.email_visit` — site visits attributed to an email, keyed by `id_message`

## Output columns

| Column | Description |
|---|---|
| `date` | Activity date (session date for accounts, session date + send offset for emails) |
| `country` | Country of the session |
| `send_interval` | Account's configured email send interval |
| `is_verified` | Whether the account is verified |
| `is_unsubscribed` | Whether the account has unsubscribed |
| `account_cnt` | Distinct accounts active for this combination |
| `sent_msg` | Distinct emails sent for this combination |
| `open_msg` | Distinct emails opened for this combination |
| `visit_msg` | Distinct site visits attributed to an email for this combination |
| `total_country_account_cnt` | Total accounts for the country, across all dates/segments |
| `total_country_sent_cnt` | Total emails sent for the country, across all dates/segments |
| `rank_total_country_account_cnt` | Country's rank by total accounts (1 = highest) |
| `rank_total_country_sent_cnt` | Country's rank by total emails sent (1 = highest) |

## Notes / assumptions

- A country appears in the result if it's in the **top 10 by either metric** — so a country can be included for high email volume even with a modest account base, or vice versa. Total row count is therefore not a clean "top 10 countries," but "top 10 by accounts, plus top 10 by sends, unioned."
- `account_cnt` and the email columns come from two different CTEs that are `0`-filled and then summed together — this is a union/pivot pattern to combine two differently-grained sources into one row per dimension group, not a sign of duplicate counting.
- `open_msg` and `visit_msg` use `LEFT JOIN`s, so unopened/unvisited emails still count toward `sent_msg` but contribute `0` to opens/visits.
- Ranks (`total_country_account_cnt`, `total_country_sent_cnt`) are computed **before** filtering, over the full dataset — they reflect true global standing, not standing within the filtered result.
- `DENSE_RANK()` means tied totals share a rank, so more than 10 countries can appear if there are ties at the 10th position.

## How to use

Run directly against the `DA` schema. No parameters required — the query returns the detailed activity breakdown for the current top-10 countries by account volume and by email volume.
