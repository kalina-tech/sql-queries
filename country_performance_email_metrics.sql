with params as (
  SELECT
acs.account_id,
s.date,
sp.country,
a.send_interval,
a.is_verified,
a.is_unsubscribed
FROM DA.session_params sp
inner join DA.account_session acs
on sp.ga_session_id=acs.ga_session_id
join DA.account a
on acs.account_id=a.id
join DA.session s
on sp.ga_session_id=s.ga_session_id),




account_metrics as(
  SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  count(DISTINCT account_id) as account_cnt,
  0 AS sent_msg,
  0 AS open_msg,
  0 AS visit_msg
from params
group by 1,2,3,4,5
),


email_metrics AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    sp.country AS country,
    a.send_interval AS send_interval,
    a.is_verified AS is_verified,
    a.is_unsubscribed AS is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM DA.email_sent es
  JOIN DA.account a ON es.id_account = a.id
  JOIN DA.account_session acs ON a.id = acs.account_id
  JOIN DA.session_params sp ON acs.ga_session_id = sp.ga_session_id
  JOIN DA.session s ON sp.ga_session_id = s.ga_session_id
  LEFT JOIN DA.email_open eo ON es.id_message = eo.id_message
  LEFT JOIN DA.email_visit ev ON es.id_message = ev.id_message
  GROUP BY 1, 2, 3, 4, 5
),


combined_base_metrics AS (
  SELECT * FROM account_metrics
  UNION ALL
  SELECT * FROM email_metrics
),
aggregated_base_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM combined_base_metrics
  GROUP BY
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed
),
with_country_totals AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM aggregated_base_metrics),
with_ranks AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM with_country_totals
)
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  account_cnt,
  sent_msg,
  open_msg,
  visit_msg,
  total_country_account_cnt,
  total_country_sent_cnt,
  rank_total_country_account_cnt,
  rank_total_country_sent_cnt
FROM with_ranks
WHERE rank_total_country_account_cnt <= 10
   OR rank_total_country_sent_cnt <= 10
