-- 1. Total Sales and Profit by Region
/*
  Purpose: This query aggregates total sales and profit per region, helping understand where revenue is strongest and which regions might need attention due to low profitability.
  Business Insights:
  - Which regions contribute the most revenue?
  - Where should financial strategies focus to improve profitability? 
*/
SELECT 
    Region, 
    FORMAT(SUM(Sales), 'C') AS Total_Sales, 
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 2. Categories Based on Profit
/*
  Purpose: This identifies the most profitable product categories, helping to decide where to allocate resources and efforts.
  Business Insights:
  - Which categories generate the highest profit?
  - Should certain product lines be expanded or prioritized?
*/
SELECT 
    Category, 
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY Category
ORDER BY SUM(Profit) DESC;


-- 3. Sales and Profit Trends by Sub-Category
/*
  Purpose: By examining sub-category performance, you can fine tune inventory strategies or pricing to maximize profit margins.
  Business Insights:
  - Which sub-categories drive the bulk of sales?
  - Are there low-profit sub-categories draining resources?
*/
SELECT 
    SubCategory, 
    FORMAT(SUM(Sales), 'C') AS Total_Sales, 
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY SubCategory
ORDER BY SUM(Sales) DESC;


-- 4. Profitability vs. Sales for Each Category
/*
  Purpose: Calculates profitability percentage per category to highlight if high sales truly translate to strong profits.
  Business Insights:
  - Are we focusing on high-sales categories that actually have poor profit margins?
  - Should we pivot resources to more profitable categories?
*/ 
SELECT 
    Category, 
    FORMAT(SUM(Sales), 'C') AS Total_Sales, 
    FORMAT(SUM(Profit), 'C') AS Total_Profit,
  Round((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Percentage
FROM Superstore
GROUP BY Category
ORDER BY Profit_Margin_Percentage DESC;


--5. Monthly Sales Trend Analysis
/*
  Purpose: Helps visualize trends over time, identifying seasonal peaks and slow periods.
  Business Insights:
  - When do sales spike, and how can we maximize profit during those times?
  - Should marketing campaigns adjust to seasonal trends?
*/
SELECT 
    FORMAT([Order Date], 'yyyy-MM') AS Month,
    FORMAT(SUM(Sales), 'C') AS Total_Sales,
    FORMAT(SUM(Profit), 'C') AS Total_Profit
FROM Superstore
GROUP BY FORMAT([Order Date], 'yyyy-MM')
ORDER BY Month ASC;


-- 6. Profitable Categories Using CTE
/*
  Purpose: Creates a temporary result set (SalesSummary) and then retrieves only profitable categories
  Business Insights:
  - Can you isolate product categories exceeding a profit threshold?
  - Should you prioritize these for promotions or scaling efforts?
*/
WITH SalesSummary AS (
    SELECT 
        Category, 
        FORMAT(SUM(Sales), 'C') AS Total_Sales,
        FORMAT(SUM(Profit), 'C') AS Total_Profit
    FROM Superstore
    GROUP BY Category
)
SELECT * FROM SalesSummary WHERE CONVERT(float,REPLACE(REPLACE(Total_Profit, ',', ''), '$', '')) > 10000;


-- 7. Regional Sales with Window Functions
/*
  Purpose: Shows individual sales while also displaying total regional sales alongside each row.
  Business Insights:
  - Can you evaluate performance at a granular level to find specific sales patterns or gaps?
  - Are there categories that should be given more focus on certain regions?
*/
SELECT 
    Region, 
    Category,
    FORMAT(Sales, 'C') AS Sales, 
    FORMAT(SUM(Sales) OVER (PARTITION BY Region), 'C') AS Regional_Sales
FROM Superstore
order by Region, Category;


-- 8. Pivoting Sales Data by Region and CategorY
/*
  Purpose: Converts rows into columns for easier reporting by displaying sales per region per category.
  Business Insights:
  - Are there areas where a more effort should be placed on marketing to drive up sales?
  - Are discounts working in all regions?
*/
SELECT 
    Category,
    FORMAT(SUM(CASE WHEN Region = 'East' THEN Sales ELSE 0 END), 'C') AS East_Sales,
    FORMAT(SUM(CASE WHEN Region = 'West' THEN Sales ELSE 0 END), 'C') AS West_Sales,
    FORMAT(SUM(CASE WHEN Region = 'South' THEN Sales ELSE 0 END), 'C') AS South_Sales,
    FORMAT(SUM(CASE WHEN Region = 'Central' THEN Sales ELSE 0 END), 'C') AS Central_Sales
FROM Superstore
GROUP BY Category;


-- 9. High Volume Customers
/*
  Purpose: Identifies high-volume customers who make frequent purchases.
  Business Insights:
  - What types of loyalty programs can marketing teams target?
  - What products are not popular with customers?
*/
SELECT [Customer ID], COUNT([Order ID]) AS Number_Orders,  FORMAT(SUM(Sales), 'C') AS Total_Sales
FROM Superstore
GROUP BY [Customer ID]
HAVING COUNT([Order ID]) > 10
ORDER BY SUM(Sales) DESC;


-- 10. Region Sales Contribution Percentage
/*
  Purpose: Shows each region's contribution to total sales.
  Business Insights:
  - Which region has the strongest sales?
  - How low is sales in the region with the smallest percentage? What can be done?
*/
WITH TotalSales AS (
    SELECT SUM(Sales) AS OverallSales FROM Superstore
)
SELECT Region, FORMAT(SUM(Sales), 'C') AS RegionalSales, 
       ROUND((SUM(Sales) * 100.0 / (SELECT OverallSales FROM TotalSales)), 2) AS Sales_Percentage
FROM Superstore
GROUP BY Region
ORDER BY Sales_Percentage DESC;


-- 11. Total Sales and Profit by Region
/*
  Purpose: Helps to asses calculates revenue performance across different regions.
  Business Insights:
  - Which regions contribute the most revenue?
  - Where should financial strategies focus to improve profitability? 
*/
WITH RegionSales AS (
    SELECT Region, FORMAT(SUM(Sales), 'C') AS Total_Sales, FORMAT(SUM(Profit), 'C') AS Total_Profit
    FROM Superstore
    GROUP BY Region
)
SELECT * FROM RegionSales
ORDER BY Total_Sales DESC;


-- 12. Customer Sales & Profit Analysis
/*
  Purpose: Helps analyze the most valuable customers by sales and profit.
  Business Insights:
  - Who are the customers spending the most money?
  - What is the correlation between customers that generate revenue but no profit?
*/
WITH CustomerLifetimeValue AS (
    SELECT [Customer ID], FORMAT(SUM(Sales), 'C') AS Lifetime_Sales, FORMAT(SUM(Profit), 'C') AS Lifetime_Profit
    FROM Superstore
    GROUP BY [Customer ID]
)
SELECT [Customer ID], Lifetime_Sales, Lifetime_Profit, --REPLACE(REPLACE(Lifetime_Sales, ',', ''), '$', '')
       RANK() OVER (ORDER BY CAST(REPLACE(REPLACE(Lifetime_Sales, ',', ''), '$', '') As FLOAT) DESC) AS Sales_Rank
FROM CustomerLifetimeValue;


-- 13. Discount Impact on Profitability
/*
  Purpose: Shows how different discount levels impact profitability.
  Business Insights:
  - Are discounts too high or too much discounts on the wrong product?
  - Should discounts be removed from certain products?

*/
SELECT Discount, FORMAT(AVG(Profit), 'C') AS Avg_Profit
FROM Superstore
GROUP BY Discount
ORDER BY Discount;


-- 14. Yearly Sales Growth
/*
  Purpose: Calculates year-over-year sales growth to assess business trends.
  Business Insights:
  - What goals can we set to continue increasing sales growth
  - Did all regions decline in growth in 2017?
*/
WITH YearlySales AS (
    SELECT YEAR([Order Date]) AS Year, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY YEAR([Order Date])
)
SELECT Year, FORMAT(Total_Sales, 'C'), 
       LAG(FORMAT(Total_Sales, 'C'),1,0) OVER (ORDER BY Year) AS Previous_Year_Sales,
       ROUND((Total_Sales - LAG(Total_Sales) OVER (ORDER BY Year)) * 100.0 / LAG(Total_Sales) OVER (ORDER BY Year), 2) AS YoY_Growth
FROM YearlySales;


-- 15. Discount by Category
/*
  Purpose: Identifies which categories receive the highest discounts.
  Business Insights:
  - How are discounts affecting revenue and profits by category?
  - Where do discounts need to be adjusted?
*/
SELECT Category, ROUND(AVG(Discount), 2) AS Avg_Discount
FROM Superstore
GROUP BY Category
ORDER BY Avg_Discount DESC;


-- 16. Monthly Sales Trend
/*
  Purpose: Helps track monthly revenue trends and identify sales fluctuations.
  Business Insights:
  - Are there trends where sales decline?
  - What incentives can be given to keep sales from declining?
*/
WITH MonthlySales AS (
    SELECT FORMAT([Order Date], 'yyyy-MM') AS Month, SUM(Sales) AS Total_Sales
    FROM Superstore
    GROUP BY FORMAT([Order Date], 'yyyy-MM')
)
SELECT Month, FORMAT(Total_Sales, 'C') AS Total_Sales, 
       FORMAT(LEAD(Total_Sales) OVER (ORDER BY Month) - Total_Sales, 'C') AS Sales_Change
FROM MonthlySales;

