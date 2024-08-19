-- Listing all tables
SELECT
 table_name
FROM
 `adwentureworks_db.INFORMATION_SCHEMA.TABLES`
WHERE
 table_type = 'BASE TABLE'
ORDER BY
 table_name;

 -- Checking row counts for all tables
SELECT
 table_id AS table_name,
 row_count
FROM
 `adwentureworks_db.__TABLES__`
ORDER BY
 row_count DESC;

 -- Examining table structure
SELECT
 column_name,
 data_type,
 is_nullable
FROM
 `adwentureworks_db.INFORMATION_SCHEMA.COLUMNS`
WHERE
 table_name = 'salesorderheader'
ORDER BY
 ordinal_position;

 -- Head query for salesorderheader
SELECT *
FROM `adwentureworks_db.salesorderheader`
ORDER BY OrderDate DESC
LIMIT 10;

-- Random sampling from salesorderheader
SELECT *
FROM `adwentureworks_db.salesorderheader`
ORDER BY RAND()
LIMIT 10;

-- Check for null values in key columns of salesorderheader
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(SalesOrderID IS NOT NULL) AS non_null_order_id,
  COUNTIF(OrderDate IS NOT NULL) AS non_null_order_date,
  COUNTIF(CustomerID IS NOT NULL) AS non_null_customer_id,
  COUNTIF(TotalDue IS NOT NULL) AS non_null_total_due,
  COUNTIF(SalesOrderID IS NULL) AS null_order_id,
  COUNTIF(OrderDate IS NULL) AS null_order_date,
  COUNTIF(CustomerID IS NULL) AS null_customer_id,
  COUNTIF(TotalDue IS NULL) AS null_total_due
FROM `adwentureworks_db.salesorderheader`;

-- Null value check in key columns in Product table
SELECT
  COUNTIF(ProductID IS NULL) AS null_product_ids,
  COUNTIF(Name IS NULL) AS null_names,
  COUNTIF(ProductNumber IS NULL) AS null_product_numbers,
  COUNTIF(Color IS NULL) AS null_colors
FROM `adwentureworks_db.product`;

-- Check for duplicate records in salesorderheader
SELECT
 SalesOrderID,
 COUNT(*) AS count
FROM
 `adwentureworks_db.salesorderheader`
GROUP BY
 SalesOrderID
HAVING
 COUNT(*) > 1;

 -- Value range check for TotalDue in salesorderheader
SELECT
  FORMAT_TIMESTAMP('%Y-%m-%d', MIN(OrderDate)) AS min_order_date,
  FORMAT_TIMESTAMP('%Y-%m-%d', MAX(OrderDate)) AS max_order_date,
  ROUND(MIN(TotalDue), 2) AS min_total_due,
  ROUND(MAX(TotalDue), 2) AS max_total_due,
  ROUND(AVG(TotalDue), 2) AS avg_total_due,
  ROUND(STDDEV(TotalDue), 2) AS stddev_total_due,
  COUNT(*) AS total_records
FROM
  `adwentureworks_db.salesorderheader`;


-- Consistency check for OrderDate and ShipDate in salesorderheader
SELECT
 COUNT(*) AS inconsistent_records
FROM (
  SELECT
  DATE(OrderDate) AS formatted_order_date,
  ShipDate
  FROM `adwentureworks_db.salesorderheader`
)
WHERE
 formatted_order_date > ShipDate;

 -- Check for unique constraint violations in Product table
SELECT
 ProductNumber,
 COUNT(*) AS count
FROM
 `adwentureworks_db.product`
GROUP BY
 ProductNumber
HAVING
 COUNT(*) > 1;