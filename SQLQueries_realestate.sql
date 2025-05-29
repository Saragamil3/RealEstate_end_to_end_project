
use RealEstate;

--Property Analytics
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


--Average price per square meter per property_type 
SELECT 
   p.PropertyType,
   ROUND(AVG(s.SalePrice / (CAST(p.lotsizesquarefeet  AS float) * 0.092903) ) ,0 ) Average_price_per_square_meter
FROM 
   Properties p
join Sales s ON p.parcelid=s.PropertyID
WHERE  p.lotsizesquarefeet <> ' '
GROUP BY p.PropertyType
ORDER BY 2 DESC ; 



--Top 10 most expensive or most visited properties
--Top 10 most expensive properties
SELECT
   TOP 10 P.parcelid PROPERTYID,
    CAST(S.SalePrice  AS INT) PRICE
FROM 
   Properties P
JOIN Sales S ON P.parcelid=S.PropertyID
ORDER BY 2 DESC ; 
--Top 10 most visited properties
SELECT
   TOP 10 P.parcelid PROPERTYID,
    COUNT(V.PropertyID) NUM_OF_VISITS
FROM 
   Properties P
JOIN Visits V ON P.parcelid=V.PropertyID
GROUP BY P.parcelid
ORDER BY 2 DESC ; 

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





--Sales Performance
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

--Average sale value per property type
SELECT
   p.PropertyType,
   CAST(
    Avg(s.SalePrice) AS INT)  Average_sale_value 
FROM
  Properties p
JOIN Sales s ON p.parcelid=s.PropertyID
WHERE p.PropertyType <> ' '
GROUP BY  p.PropertyType
ORDER BY 2 desc; 

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


--Agent Performance
--TOP 10 AGENTS IN TERMS OF SALES TRANSACTIONS
SELECT 
    TOP 10 CONCAT(A.FirstName,' ',A.LastName) FULL_NAME,
	COUNT(DISTINCT S.PropertyID) NUM_OF_SALES
FROM Agents A 
JOIN Sales S ON A.AgentID=S.AgentID
WHERE PropertyID IS NOT NULL
GROUP BY CONCAT(A.FirstName,' ',A.LastName)
ORDER BY 2 DESC; 

--Number of client visits per agent
SELECT 
   CONCAT(A.FirstName,' ',A.LastName) FULL_NAME,
   COUNT(DISTINCT V.AgentID) NUM_OF_CLIENT
FROM Agents A 
JOIN Visits V ON A.AgentID=V.AgentID
GROUP BY CONCAT(A.FirstName,' ',A.LastName) 
ORDER BY 2 DESC; 

--Conversion rate per agent (visits → sales)
CREATE VIEW CONVERSION_RATE_PER_AGENT
AS 
SELECT 
    CONCAT(A.FirstName,' ',A.LastName) AGENT_NAME ,
	COUNT(DISTINCT S.SaleID) NUM_OF_SALES,
	COUNT(DISTINCT V.VisitID) NUM_OF_VISITS,
	   CASE 
        WHEN COUNT(DISTINCT S.SaleID) = 0 OR COUNT(DISTINCT V.VisitID)=0 THEN 0
        ELSE CAST(ROUND((COUNT(DISTINCT S.SaleID) *1.0 /COUNT(DISTINCT V.VisitID) ) *100 ,0) AS INT) 
    END AS conversion_rate
FROM Agents A
LEFT JOIN Sales S ON S.AgentID=A.AgentID
LEFT JOIN Visits V ON V.AgentID=A.AgentID
GROUP BY CONCAT( A.FirstName,' ',A.LastName) 

--SELECT AGENTS WHO GOT 100% OF CONVERSION RATE
SELECT
     AGENT_NAME,
	 NUM_OF_SALES,
	 NUM_OF_VISITS,
	CONCAT(conversion_rate, '%') CONVERSIONRATE
FROM CONVERSION_RATE_PER_AGENT
WHERE conversion_rate=100
-- TOP AGENTS WHO SOLD PROPERTIES WITHOUT VISIT THEM AND THE NUMBER OF THESE PROPERTIES
SELECT
     TOP 10 AGENT_NAME,
	 NUM_OF_SALES,
	 NUM_OF_VISITS,
	 (NUM_OF_SALES-NUM_OF_VISITS) SOLD_PROP_WITHOUT_VISITING
FROM CONVERSION_RATE_PER_AGENT
WHERE NUM_OF_SALES>NUM_OF_VISITS
ORDER BY NUM_OF_SALES DESC 

--Avg sale value handled by each agent
SELECT 
   TOP 10 CONCAT(A.FirstName,' ',A.LastName) FULL_NAME,
   CAST(AVG(DISTINCT S.SalePrice) AS INT) AVG_OF_SALES
FROM
  Agents A 
JOIN Sales S ON A.AgentID=S.AgentID
GROUP BY   CONCAT(A.FirstName,' ',A.LastName) 
ORDER BY 2 DESC ;




--Client Engagement
--Number of properties visited per client
SELECT 
    CONCAT(C.FirstName,' ',C.LastName) CLIENTNAME,
	COUNT(DISTINCT V.PropertyID) NUM_OF_PROPERTIES
FROM Clients C 
JOIN Visits V ON C.ClientID=V.ClientID 
GROUP BY CONCAT(C.FirstName,' ',C.LastName)
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













