-- Basic statistics for salesorderheader
SELECT
 ROUND(MIN(TotalDue), 2) AS min_total_due,
 ROUND(MAX(TotalDue), 2) AS max_total_due,
 ROUND(AVG(TotalDue), 2) AS avg_total_due,
 COUNT(DISTINCT CustomerID) AS unique_customers,
 COUNT(DISTINCT SalesPersonID) AS unique_salespersons
FROM `adwentureworks_db.salesorderheader`;

-- Distribution of order total amounts
SELECT
 CASE
   WHEN TotalDue < 100 THEN '0-100'
   WHEN TotalDue < 500 THEN '100-500'
   WHEN TotalDue < 1000 THEN '500-1000'
   WHEN TotalDue < 5000 THEN '1000-5000'
   ELSE '5000+'
 END AS total_due_range,
 COUNT(*) AS order_count
FROM `adwentureworks_db.salesorderheader`
GROUP BY total_due_range
ORDER BY total_due_range;

-- Sales by Year with Growth Rate
WITH yearly_sales AS (
  SELECT
    FORMAT_TIMESTAMP('%Y', OrderDate) AS year,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalDue), 2) AS total_sales
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    year
)
SELECT
  year,
  order_count,
  total_sales,
  LAG(total_sales) OVER (ORDER BY year) AS previous_year_sales,
  ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year)) / LAG(total_sales) OVER (ORDER BY year) * 100, 2) AS growth_rate
FROM
  yearly_sales
ORDER BY
  year;

-- Sales by Quarter with Growth Rate
WITH quarterly_sales AS (
  SELECT
    EXTRACT(YEAR FROM OrderDate) AS year,
    EXTRACT(QUARTER FROM OrderDate) AS quarter,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalDue), 2) AS total_sales
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    year,
    quarter
)
SELECT
  year,
  quarter,
  order_count,
  total_sales,
  LAG(total_sales) OVER (ORDER BY year, quarter) AS previous_quarter_sales,
  ROUND((total_sales - LAG(total_sales) OVER (ORDER BY year, quarter)) / LAG(total_sales) OVER (ORDER BY year, quarter) * 100, 2) AS growth_rate
FROM
  quarterly_sales
ORDER BY
  year,
  quarter;

-- Sales by Month
WITH monthly_sales AS (
  SELECT
    FORMAT_TIMESTAMP('%Y-%m', OrderDate) AS month,
    COUNT(*) AS order_count,
    ROUND(SUM(TotalDue), 2) AS total_sales
  FROM
    `adwentureworks_db.salesorderheader`
  GROUP BY
    month
)
SELECT
  month,
  order_count,
  total_sales,
  LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
  ROUND((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month) * 100, 2) AS growth_rate
FROM
  monthly_sales
ORDER BY
  month;

-- Sales by Day of Week
SELECT
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM OrderDate) = 1 THEN 7
    ELSE EXTRACT(DAYOFWEEK FROM OrderDate) - 1
  END AS day_of_week,
  COUNT(*) AS order_count,
  ROUND(SUM(TotalDue), 2) AS total_sales
FROM
  `adwentureworks_db.salesorderheader`
GROUP BY
  day_of_week
ORDER BY
  day_of_week;

-- Salesperson Performance with Targets on a Yearly Basis including Bonus Calculation
WITH SalesData AS (
  SELECT
    sp.SalesPersonID,
    EXTRACT(YEAR FROM soh.OrderDate) AS sales_year,
    COUNT(DISTINCT soh.SalesOrderID) AS order_count,
    ROUND(SUM(soh.TotalDue), 2) AS total_sales,
    ROUND(SUM(DISTINCT sp.SalesQuota), 2) AS sales_quota,
    ROUND(SUM(DISTINCT sp.Bonus), 2) AS bonus
  FROM
    `adwentureworks_db.salesperson` sp
  JOIN
    `adwentureworks_db.salesorderheader` soh ON sp.SalesPersonID = soh.SalesPersonID
  WHERE
    sp.SalesQuota IS NOT NULL
  GROUP BY
    sp.SalesPersonID,
    sales_year
)
SELECT
  SalesPersonID,
  sales_year,
  order_count,
  total_sales,
  sales_quota,
  CASE 
    WHEN total_sales > sales_quota THEN 'Achieved Quota'
    ELSE 'Did Not Achieve Quota'
  END AS quota_achievement,
  CASE
    WHEN total_sales >= sales_quota THEN bonus
    ELSE 0
  END AS calculated_bonus
FROM
  SalesData
ORDER BY
  total_sales DESC;

-- Salesperson Commission Calculation
SELECT
  sp.SalesPersonID,
  ROUND(SUM(soh.TotalDue), 2) AS total_sales,
  sp.CommissionPct,
  ROUND(SUM(soh.TotalDue) * sp.CommissionPct, 2) AS commission
FROM
  `adwentureworks_db.salesperson` sp
JOIN
  `adwentureworks_db.salesorderheader` soh ON sp.SalesPersonID = soh.SalesPersonID
GROUP BY
  sp.SalesPersonID, sp.CommissionPct
ORDER BY
  total_sales DESC;

-- Salesperson Performance by Territory
SELECT
  st.CountryRegionCode AS territory_name,
  sp.SalesPersonID,
  COUNT(DISTINCT soh.SalesOrderID) AS order_count,
  ROUND(SUM(soh.TotalDue), 2) AS total_sales,
  sp.SalesYTD,
  sp.SalesLastYear
FROM
  `adwentureworks_db.salesperson` sp
JOIN
  `adwentureworks_db.salesorderheader` soh ON sp.SalesPersonID = soh.SalesPersonID
JOIN
  `adwentureworks_db.salesterritory` st ON soh.TerritoryID = st.TerritoryID
GROUP BY
  st.CountryRegionCode, sp.SalesPersonID, sp.SalesYTD, sp.SalesLastYear
ORDER BY
  total_sales DESC;