-- Top 10 Customers by Total Purchase
SELECT
    c.CustomerID,
    ROUND(SUM(soh.TotalDue), 2) AS total_purchase
FROM `adwentureworks_db.customer` c
JOIN `adwentureworks_db.salesorderheader` soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY total_purchase DESC
LIMIT 10;

  -- Top Customers by Order Count
SELECT
  CustomerID,
  COUNT(SalesOrderID) AS order_count
FROM
  `adwentureworks_db.salesorderheader`
GROUP BY
  CustomerID
ORDER BY
  order_count DESC
LIMIT
  10;

  -- Average Order Value by Customer
SELECT
  CustomerID,
  ROUND(AVG(TotalDue), 2) AS avg_order_value
FROM
  `adwentureworks_db.salesorderheader`
GROUP BY
  CustomerID
ORDER BY
  avg_order_value DESC
LIMIT
  10;

-- Customer segmentation by purchase frequency and total spend
SELECT
    CustomerID,
    COUNT(DISTINCT SalesOrderID) AS order_count,
    ROUND(SUM(TotalDue), 2) AS total_spend,
    CASE
        WHEN COUNT(DISTINCT SalesOrderID) > 10 AND SUM(TotalDue) > 10000 THEN 'High Value'
        WHEN COUNT(DISTINCT SalesOrderID) > 5 OR SUM(TotalDue) > 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM `adwentureworks_db.salesorderheader`
GROUP BY CustomerID
ORDER BY total_spend DESC
LIMIT 200;