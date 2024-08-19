-- Sales by Country
SELECT
    st.CountryRegionCode AS country,
    COUNT(soh.SalesOrderID) AS order_count,
    ROUND(SUM(soh.TotalDue), 0) AS total_sales
FROM `adwentureworks_db.salesterritory` st
JOIN `adwentureworks_db.salesorderheader` soh ON st.TerritoryID = soh.TerritoryID
GROUP BY st.CountryRegionCode
ORDER BY total_sales DESC;

-- Sales by Territory
SELECT
    st.Name AS territory_name,
    COUNT(soh.SalesOrderID) AS order_count,
    ROUND(SUM(soh.TotalDue), 0) AS total_sales
FROM `adwentureworks_db.salesterritory` st
JOIN `adwentureworks_db.salesorderheader` soh ON st.TerritoryID = soh.TerritoryID
GROUP BY st.Name
ORDER BY total_sales DESC;

-- Sales Growth by Territory
WITH territory_sales AS (
    SELECT
        st.Name AS territory_name,
        FORMAT_DATE('%Y-%m', soh.OrderDate) AS order_month,
        ROUND(SUM(soh.TotalDue), 0) AS total_sales
    FROM `adwentureworks_db.salesterritory` st
    JOIN `adwentureworks_db.salesorderheader` soh ON st.TerritoryID = soh.TerritoryID
    GROUP BY st.Name, order_month
)
SELECT
    territory_name,
    order_month,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY territory_name ORDER BY order_month) AS previous_month_sales,
    ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY territory_name ORDER BY order_month)) / LAG(total_sales) OVER (PARTITION BY territory_name ORDER BY order_month) * 100, 2) AS growth_rate
FROM territory_sales
ORDER BY territory_name, order_month;