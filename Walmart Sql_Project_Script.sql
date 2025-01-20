CREATE DATABASE SQL_Project;
USE sql_project;

SELECT * FROM walmartsales_data_set; 
/* Task 1: Identifying the Top Branch by Sales Growth Rate 
Walmart wants to identify which branch has exhibited the highest sales growth over time. Analyze the total sales
for each branch and compare the growth rate across months to find the top performer.*/

CREATE VIEW Walmarts_Monthly_sales_by_branch AS
SELECT MONTH(Updated_Date) AS month, Branch, SUM(Total) AS total_sale
FROM walmartsales_data_set
GROUP BY Branch, month;

SELECT * FROM Walmarts_Monthly_sales_by_branch;

SELECT c.Branch, c.total_sale, c.month AS Current_sale_month, p.total_sale AS prev_total_sale,
ROUND (((c.total_sale-p.total_sale) / p.total_sale)*100, 2) AS Growth_Rate
FROM Walmarts_Monthly_sales_by_branch c
INNER JOIN 
( SELECT Branch, total_sale, month FROM Walmarts_Monthly_sales_by_branch) P
ON c.Branch = p.Branch AND c.month = p.month+1
ORDER BY Growth_Rate DESC
LIMIT 1;

/* Task 2: Finding the Most Profitable Product Line for Each Branch.
Walmart needs to determine which product line contributes the highest profit to each branch.The profit margin
should be calculated based on the difference between the gross income and cost of goods sold.*/

CREATE VIEW Most_Profitable_product_line_of AS
SELECT Branch, Product_line, SUM(gross_income) AS Total_Gross_income
FROM walmartsales_data_set
GROUP BY Branch, Product_line;

SELECT * FROM Most_Profitable_Product_line_of ;

SELECT Branch, Product_line, Total_Gross_income 
FROM( SELECT  Branch, Product_line, Total_Gross_income, 
RANK()OVER(PARTITION BY Branch ORDER BY  Total_Gross_income DESC) AS Rank_inc
FROM Most_Profitable_Product_line_of) AS Ranked_Product
WHERE Rank_inc = 1;

/* Task 3: Analyzing Customer Segmentation Based on Spending.
Walmart wants to segment customers based on their average spending behavior. Classify customers into three
tiers: High, Medium, and Low spenders based on their total purchase amounts.*/

SELECT * FROM walmartsales_data_set;

CREATE VIEW average_of_spendings AS
SELECT Customer_ID,COUNT(Customer_ID) AS Total_of_CustomerID, AVG(Total) AS average_spending
FROM walmartsales_data_set
GROUP BY Customer_ID;

SELECT * FROM average_of_spendings;

SELECT Customer_ID, average_spending,
CASE
WHEN average_spending < 300 THEN 'Low_Spenders'
WHEN average_spending > 300 AND average_spending < 340 THEN 'Medium_Spenders'
ELSE 'High_Spenders' END AS Spenders_Lavel
FROM average_of_spendings;


/* Task 4: Detecting Anomalies in Sales Transactions.
Walmart suspects that some transactions have unusually high or low sales compared to the average for the
product line. Identify these anomalies.*/

SELECT * FROM walmartsales_data_set;

CREATE VIEW average_product_lines AS
SELECT Product_line, AVG(Total) AS Average_Total_Sales
FROM walmartsales_data_set
GROUP BY Product_line;

SELECT * FROM average_product_lines;

SELECT w.Product_line, w.Total, p.Average_Total_Sales,
CASE
WHEN w.Total > p.Average_Total_Sales *2 THEN 'Anomaly'
WHEN w.Total < p.Average_Total_Sales /2 THEN 'Few_Anomaly_only'
ELSE 'No_Anomaly' END AS Transactions_Anomalies
FROM walmartsales_data_set w
LEFT JOIN 
average_product_line p ON  w.Product_line = p.Product_line

/* Task 5: Most Popular Payment Method by City.
Walmart needs to determine the most popular payment method in each city to tailor marketing strategies.*/

SELECT City, Payment, COUNT(Payment) AS TOTAL_NO_METHOD
FROM walmartsales_data_set
GROUP BY City, Payment
ORDER BY City, Payment DESC ;

CREATE VIEW Payment_Method_rank AS
(SELECT City, Payment, COUNT(Payment) AS TOTAL_NO_METHOD,
RANK() OVER (PARTITION BY City ORDER BY COUNT(Payment) DESC) AS Rank_of_payment
FROM walmartsales_data_set
GROUP BY City, Payment);
SELECT * FROM Payment_Method_rank;

SELECT  City, Payment, TOTAL_NO_METHOD, Rank_of_payment
FROM Payment_Method_rank
WHERE Rank_of_payment = 1;

/* Task 6: Monthly Sales Distribution by Gender.
Walmart wants to understand the sales distribution between male and female customers on a monthly basis.*/

SELECT Gender, SUM(Total) AS Total_sales, MONTH(STR_TO_DATE(Updated_Date, '%d-%m-%Y')) AS Month_of_sale
FROM walmartsales_data_set
GROUP BY 
Gender, Month_of_sale
ORDER BY 
Gender, Month_of_sale DESC ;

SELECT Gender, MONTH(Updated_Date) AS Month_of_sale, 
SUM(Total) AS Total_sales
FROM walmartsales_data_set
GROUP BY 
Gender, MONTH(Updated_Date)
ORDER BY 
Gender, Month_of_sale ASC;

/* Task 7: Best Product Line by Customer Type.
Walmart wants to know which product lines are preferred by different customer types(Member vs. Normal).*/

SELECT Product_line, Customer_type, SUM(Total) AS ProductLines_Totalsales
FROM walmartsales_data_set
GROUP BY Product_line, Customer_type
ORDER BY Customer_type, ProductLines_Totalsales DESC;

/* Task 8: Identifying Repeat Customers.
Walmart needs to identify customers who made repeat purchases within a specific time frame(e.g., within 30
days).*/

SET SQL_SAFE_UPDATES = 0;

UPDATE walmartsales_data_set
SET Updated_Date = REPLACE(Updated_Date, '/', '-');

SELECT Customer_ID, COUNT(*) AS repeat_purchases
FROM walmartsales_data_set
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

/* Task 9: Finding Top 5 Customers by Sales Volume
Walmart wants to reward its top 5 customers who have generated the most sales Revenue.*/

SELECT Customer_ID, SUM(Total) AS Total_Sales_revenue
FROM walmartsales_data_set
GROUP BY Customer_ID
ORDER BY Total_Sales_revenue DESC
LIMIT 5;

/* Task 10: Analyzing Sales Trends by Day of the Week. 
Walmart wants to analyze the sales patterns to determine which day of the week
brings the highest sales.*/ 

SELECT DAYNAME(Updated_Date) AS Day_Name, DAYOFWEEK(Updated_Date) AS Day_Number, 
SUM(Total) AS Total_sale
FROM walmartsales_data_set
GROUP BY 
Day_Name, Day_Number
ORDER BY 
Total_sale DESC;