# 📊 Superstore Sales & Profitability Analysis

This repository contains a series of SQL queries designed to analyze sales and profitability data from the Superstore dataset. Each query is accompanied by a business-oriented summary to provide insights for strategic decision-making.

---

## 1. Total Sales and Profit by Region

```sql
SELECT
    Region,
    FORMAT(SUM(Sales), 'C') AS Total_Sales,
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY Region
ORDER BY Total_Sales DESC;
```

**Summary:**
This query aggregates total sales and profit for each region. It helps identify which regions are generating the most revenue and profit, enabling executives to focus on high-performing areas and address underperforming ones.

---

## 2. Categories Based on Profit

```sql
SELECT
    Category,
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY Category
ORDER BY SUM(Profit) DESC;
```

**Summary:**
This query ranks product categories by total profit. It assists in determining which categories are most lucrative, guiding resource allocation and marketing efforts toward high-profit segments.

---

## 3. Sales and Profit Trends by Sub-Category

```sql
SELECT
    SubCategory,
    FORMAT(SUM(Sales), 'C') AS Total_Sales,
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY SubCategory
ORDER BY SUM(Sales) DESC;
```

**Summary:**
This query provides sales and profit data for each sub-category. It aids in identifying top-performing sub-categories and those that may require strategic adjustments.

---

## 4. Profitability vs. Sales for Each Category

```sql
SELECT
    Category,
    FORMAT(SUM(Sales), 'C') AS Total_Sales,
    FORMAT(SUM(Profit), 'C') AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percentage
FROM Superstore
GROUP BY Category
ORDER BY Profit_Margin_Percentage DESC;
```

**Summary:**
This query calculates the profit margin percentage for each category. It reveals whether high sales volumes are translating into strong profits, informing decisions on product focus and pricing strategies.

---

## 5. Monthly Sales Trend Analysis

```sql
SELECT
    FORMAT([Order Date], 'yyyy-MM') AS Month,
    FORMAT(SUM(Sales), 'C') AS Total_Sales,
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY FORMAT([Order Date], 'yyyy-MM')
ORDER BY Month ASC;
```

**Summary:**
This query tracks monthly sales and profit trends. It helps identify seasonal patterns, enabling timely marketing campaigns and inventory planning.

---

## 6. Profitable Categories Using CTE

```sql
WITH SalesSummary AS (
    SELECT
        Category,
        FORMAT(SUM(Sales), 'C') AS Total_Sales,
        FORMAT(SUM(Profit), 'C') AS Total_Profit
    FROM Superstore
    GROUP BY Category
)
SELECT * FROM SalesSummary
WHERE CONVERT(float, REPLACE(REPLACE(Total_Profit, ',', ''), '$', '')) > 10000;
```

**Summary:**
This query uses a Common Table Expression (CTE) to identify categories with profits exceeding \$10,000. It simplifies complex queries and highlights high-performing categories.

---

## 7. Regional Sales with Window Functions

```sql
SELECT
    Region,
    Category,
    Sales,
    FORMAT(SUM(Sales) OVER (PARTITION BY Region), 'C') AS Regional_Sales
FROM Superstore
ORDER BY Region, Category;
```

**Summary:**
This query employs window functions to display individual sales alongside total regional sales. It provides context for each sale within its regional performance.

---

## 8. Pivoting Sales Data by Region and Category

```sql
SELECT
    Category,
    FORMAT(SUM(CASE WHEN Region = 'East' THEN Sales ELSE 0 END), 'C') AS East_Sales,
    FORMAT(SUM(CASE WHEN Region = 'West' THEN Sales ELSE 0 END), 'C') AS West_Sales
FROM Superstore
GROUP BY Category;
```

**Summary:**
This query pivots sales data to show sales per region for each category. It facilitates comparative analysis across regions.

---

## 9. High Volume Customers

```sql
SELECT [Customer ID], COUNT([Order ID]) AS Number_Orders, FORMAT(SUM(Sales), 'C') AS Total_Sales
FROM Superstore
GROUP BY [Customer ID]
HAVING COUNT([Order ID]) > 10
ORDER BY SUM(Sales) DESC;
```

**Summary:**
This query identifies customers with more than 10 orders. It helps in recognizing loyal customers for targeted marketing and retention strategies.

---

## 10. Region Sales Contribution Percentage

```sql
WITH TotalSales AS (
    SELECT SUM(Sales) AS OverallSales FROM Superstore
)
SELECT Region, FORMAT(SUM(Sales), 'C') AS RegionalSales,
       ROUND((SUM(Sales) * 100.0 / (SELECT OverallSales FROM TotalSales)), 2) AS Sales_Percentage
FROM Superstore
GROUP BY Region
ORDER BY Sales_Percentage DESC;
```

**Summary:**
This query calculates each region's contribution to total sales. It assists in resource allocation and strategic planning based on regional performance.

---

## 11. Total Sales and Profit by Region Using CTE

```sql
WITH RegionSales AS (
    SELECT Region, FORMAT(SUM(Sales), 'C') AS Total_Sales, FORMAT(SUM(Profit), 'C') AS Total_Profit
    FROM Superstore
    GROUP BY Region
)
SELECT * FROM RegionSales
ORDER BY Total_Sales DESC;
```

**Summary:**
This query uses a CTE to calculate total sales and profit by region. It provides a clear view of regional performance for financial assessment.

---

## 12. Customer Sales & Profit Analysis

```sql
WITH CustomerLifetimeValue AS (
    SELECT [Customer ID], SUM(Sales) AS Lifetime_Sales, SUM(Profit) AS Lifetime_Profit
    FROM Superstore
    GROUP BY [Customer ID]
)
SELECT [Customer ID], Lifetime_Sales, Lifetime_Profit,
       RANK() OVER (ORDER BY Lifetime_Sales DESC, Lifetime_Profit DESC) AS Sales_Rank
FROM CustomerLifetimeValue;
```

**Summary:**
This query analyzes customer lifetime sales and profit, ranking customers accordingly. It helps in identifying top customers for loyalty programs and personalized marketing.

---

## 13. Discount Impact on Profitability

```sql
SELECT Discount, FORMAT(AVG(Profit), 'C') AS Avg_Profit
FROM Superstore
GROUP BY Discount
ORDER BY Discount;
```

**Summary:**
This query examines how different discount levels affect average profit. It informs pricing strategies to balance discounts with profitability.

---

## 14. Yearly Sales Growth

```sql
WITH YearlySales AS (
    SELECT YEAR([Order Date]) AS Year, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY YEAR([Order Date])
)
SELECT Year, FORMAT(Total_Sales, 'C') AS Total_Sales,
       FORMAT(LAG(Total_Sales) OVER (ORDER BY Year), 'C') AS Previous_Year_Sales,
       ROUND((Total_Sales - LAG(Total_Sales) OVER (ORDER BY Year)) * 100.0 / LAG(Total_Sales) OVER (ORDER BY Year), 2) AS YoY_Growth
FROM YearlySales;
```

**Summary:**
This query calculates year-over-year sales growth. It aids in assessing business trends and forecasting future performance.

---

## 15. Discount by Category

```sql
SELECT Category, ROUND(AVG(Discount), 2) AS Avg_Discount
FROM Superstore
GROUP BY Category
ORDER BY Avg_Discount DESC;
```

**Summary:**
This query calculates the average discount for each category. It helps in evaluating discount strategies and their alignment with profitability goals.

---

## 16. Monthly Sales Trend

```sql
WITH MonthlySales AS (
    SELECT FORMAT([Order Date], 'yyyy-MM') AS Month, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY FORMAT([Order Date], 'yyyy-MM')
)
SELECT Month, FORMAT(Total_Sales, 'C') AS Total_Sales,
       FORMAT(LEAD(Total_Sales) OVER (ORDER BY Month) - Total_Sales, 'C') AS Sales_Change
FROM MonthlySales;
```

**Summary:**
This query tracks monthly sales and calculates the change in sales month-over-month. It assists in identifying sales trends and making timely business decisions.

---

These SQL queries provide valuable insights into sales and profitability, supporting data-driven decisions in finance and marketing.
