-- Top selling products
SELECT
 p.Name AS product_name,
 SUM(sod.OrderQty) AS total_quantity_sold,
 ROUND(SUM(sod.LineTotal), 0) AS total_revenue
FROM `adwentureworks_db.salesorderdetail` sod
JOIN `adwentureworks_db.product` p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Best-Selling Products
SELECT
    p.ProductID,
    p.Name AS product_name,
    SUM(sod.OrderQty) AS total_quantity_sold,
    ROUND(SUM(sod.LineTotal), 0) AS total_revenue
FROM `adwentureworks_db.product` p
JOIN `adwentureworks_db.salesorderdetail` sod ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Product Category distribution
SELECT
    pc.Name AS category_name,
    COUNT(*) AS product_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `adwentureworks_db.product` p
JOIN `adwentureworks_db.productsubcategory` ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY product_count DESC;

  -- Sales by Product Category
SELECT
  pc.Name AS category_name,
  ROUND(SUM(sod.LineTotal), 0) AS total_sales
FROM `adwentureworks_db.salesorderdetail` sod
JOIN `adwentureworks_db.product` p ON sod.ProductID = p.ProductID
JOIN `adwentureworks_db.productsubcategory` ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY total_sales DESC;

-- Product List Price statistics
SELECT
    MIN(ListPrice) AS min_price,
    MAX(ListPrice) AS max_price,
    ROUND(AVG(ListPrice), 2) AS avg_price,
    ROUND(STDDEV(ListPrice), 2) AS stddev_price
FROM `adwentureworks_db.product`
WHERE ListPrice > 0;

-- Category vs. Average List Price
SELECT
    pc.Name AS category_name,
    ROUND(AVG(p.ListPrice), 2) AS avg_list_price
FROM `adwentureworks_db.product` p
JOIN `adwentureworks_db.productsubcategory` ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY avg_list_price DESC;

-- Product sales trend over time
SELECT
    p.ProductID,
    p.Name AS product_name,
    FORMAT_DATE('%Y-%m', soh.OrderDate) AS order_month,
    SUM(sod.OrderQty) AS quantity_sold,
    ROUND(SUM(sod.LineTotal), 2) AS total_revenue
FROM `adwentureworks_db.product` p
JOIN `adwentureworks_db.salesorderdetail` sod ON p.ProductID = sod.ProductID
JOIN `adwentureworks_db.salesorderheader` soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY p.ProductID, p.Name, order_month
ORDER BY p.ProductID, order_month
-- LIMIT 20;

  -- Product inventory analysis
SELECT
  p.ProductID,
  p.Name AS product_name,
  p.SafetyStockLevel,
  pi.Quantity AS current_inventory,
  CASE
    WHEN pi.Quantity < p.SafetyStockLevel THEN 'Low Stock'
    WHEN pi.Quantity > p.SafetyStockLevel * 2 THEN 'Overstocked'
    ELSE 'Adequate'
END
  AS inventory_status
FROM
  `adwentureworks_db.product` p
JOIN
  `adwentureworks_db.productinventory` pi
ON
  p.ProductID = pi.ProductID
ORDER BY
  pi.Quantity DESC
LIMIT
  200;