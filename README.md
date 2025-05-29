# RealEstate_End_To_End_Project

# Project Stages

- Azure Cloud
   - Created an Azure SQL Server database.
   - Connected the Azure SQL Database to SQL Server Management Studio (SSMS).

- SQL Server Management Studio (SSMS)
   - Designed and created the database schema.
   - Imported data files into the database.
   - Wrote SQL queries to clean, transform, and analyze the data.
- Power BI
   - Connected Power BI to the Azure SQL Database.
   - Cleaned and transformed data using Power Query.
   - Utilized DAX functions for advanced data analysis.
   - Developed interactive visual reports and dashboards.
- Python
   - Built a data pipeline integrated with SQL Server.
   - Performed data analysis using Python libraries.
# Create Azure SQL Server Database
  ![azure](https://github.com/Saragamil3/RealEstate_end_to_end_project/blob/main/Screenshot%202025-05-23%20161830.png)
# SQL server management system 
- Database Creation
  ![ERD](https://github.com/Saragamil3/RealEstate_end_to_end_project/blob/main/Screenshot%202025-05-26%20140043.png)
- The most important SQL Queries
```sql
-- property type distribution
SELECT
  PropertyType,
  COUNT(distinct parcelid)  Num_of_properties
FROM
   dbo.Properties
where 
   PropertyType <> ' '
GROUP BY PropertyType
ORDER BY 2 DESC ; 

--Total sales value over time (monthly, quarterly)
SELECT
   DATEPART(qq, SaleDate) 'QUARTER',
   DATEPART(m, SaleDate) 'MONTH',
   ROUND(
      CAST(
	  SUM(SalePrice) AS FLOAT) ,0) Total_Sales
FROM
   Sales 
GROUP BY  DATEPART(qq, SaleDate), DATEPART(M, SaleDate)
ORDER BY 1,2 ;

-- number of not sold properties
select 
   count(p.parcelid) num_of_not_sold_properties
from Properties p
where  NOT EXISTS (select s.PropertyID from  Sales s where p.parcelid=s.PropertyID )
 --number of sold properties
select 
   count(p.parcelid) num_of_sold_properties
from Properties p 
join sales s on p.parcelid=s.PropertyID

--Conversion rate = (sales / visits) per property 
CREATE VIEW CONVERSION_RATE_PER_PROPERTY
AS 
SELECT 
    P.parcelid,
	COUNT(DISTINCT S.SaleID) NUM_OF_SALES,
	COUNT(DISTINCT V.VisitID) NUM_OF_VISITS,
	   CASE 
        WHEN COUNT(DISTINCT S.SaleID) = 0 OR COUNT(DISTINCT V.VisitID)=0 THEN 0
        ELSE CAST(ROUND((COUNT(DISTINCT S.SaleID) *1.0 /COUNT(DISTINCT V.VisitID) ) *100 ,0) AS INT) 
    END AS conversion_rate
FROM Properties P
LEFT JOIN Sales S ON S.PropertyID=P.parcelid
LEFT JOIN Visits V ON V.PropertyID=P.parcelid
GROUP BY P.parcelid 
--PROPERTIES THAT GOT 100% CONVERSIONRATE
SELECT
   parcelid,
   NUM_OF_SALES,
   NUM_OF_VISITS,
   CONCAT(conversion_rate,'%') CONVERSIONRATE
FROM CONVERSION_RATE_PER_PROPERTY
WHERE conversion_rate=100
ORDER BY conversion_rate DESC

--TOP 10 AGENTS IN TERMS OF SALES TRANSACTIONS
SELECT 
    TOP 10 CONCAT(A.FirstName,' ',A.LastName) FULL_NAME,
	COUNT(DISTINCT S.PropertyID) NUM_OF_SALES
FROM Agents A 
JOIN Sales S ON A.AgentID=S.AgentID
WHERE PropertyID IS NOT NULL
GROUP BY CONCAT(A.FirstName,' ',A.LastName)
ORDER BY 2 DESC;

--Avg sale value handled by each agent
SELECT 
   TOP 10 CONCAT(A.FirstName,' ',A.LastName) FULL_NAME,
   CAST(AVG(DISTINCT S.SalePrice) AS INT) AVG_OF_SALES
FROM
  Agents A 
JOIN Sales S ON A.AgentID=S.AgentID
GROUP BY   CONCAT(A.FirstName,' ',A.LastName) 
ORDER BY 2 DESC ;

--Top clients by sale value
SELECT 
    TOP 5 CONCAT(C.FirstName,' ',C.LastName) CLIENTNAME,
	CAST(SUM(DISTINCT S.SalePrice) AS INT) SALES_VALUE
FROM 
    Clients C 
JOIN Sales S ON C.ClientID=S.ClientID
GROUP BY CONCAT(C.FirstName,' ',C.LastName)
ORDER BY 2 DESC ;

--First-time vs repeat buyers clients
CREATE VIEW NUM_OF_TRANSACTIONS 
AS
SELECT 
  CONCAT(C.FirstName,' ',C.LastName) CLIENTNAME,
  COUNT(DISTINCT S.SaleID) NUM_OF_TRANSACTIONS,
  CASE 
   WHEN COUNT(DISTINCT S.SaleID) =1 THEN 'First_time'
   WHEN COUNT(DISTINCT S.SaleID)>1 THEN 'Repeat_Buyers'
   ELSE  'NEVER_BUY' 
   END CLIENT_STATUS
FROM Clients C
LEFT JOIN SALES S ON C.ClientID=S.ClientID
GROUP BY CONCAT(C.FirstName,' ',C.LastName) ; 

--NUMER OF CLIENTS PER CLIENT_STATUS
SELECT 
    CLIENT_STATUS,
    COUNT(CLIENT_STATUS) NUM_OF_CLIENTS  
FROM NUM_OF_TRANSACTIONS 
GROUP BY CLIENT_STATUS
```
