# revenue-query
This query calculates the cumulative percentage of actual revenue relative to predicted goals day by day.  It aggregates daily actuals and predictions, merges them by date, and uses running totals (SUM() OVER (ORDER BY date)) to divide cumulative actuals by cumulative predictions, showing overall progress over time.
