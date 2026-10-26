
## Exo 1

SELECT *
FROM Production.Product
WHERE ListPrice > 
	(SELECT AVG(ListPrice)
	FROM Production.Product)

## Exo 2
WITH Prix_moyen AS (
	SELECT AVG (ListPrice) AS Moyenne
	FROM Production.Product
)

SELECT *
FROM Production.Product
WHERE ListPrice > (SELECT Moyenne 
				   FROM Prix_moyen)

## Exo 3 
WITH CA_Global AS 
	(
	SELECT
		SalesOrderID,
		SUM(Totaldue) AS Totaldue
	FROM Sales.SalesOrderHeader
	GROUP BY SalesOrderID
	)

SELECT *
FROM CA_Global
WHERE Totaldue > 10000

## Exo 4
SELECT 
	SalesOrderID,
	OrderDate,
	DATENAME (Weekday,OrderDate) as day,
	DATENAME(MONTH, Orderdate) as month,
	DATENAME(YEAR, Orderdate) as year,
	DATEDIFF(day, orderdate, shipdate)

FROM Sales.SalesOrderHeader

## Exo 5
SELECT DISTINCT c.CustomerID
FROM Sales.Customer c
WHERE EXISTS (
    SELECT 1
    FROM Sales.SalesOrderHeader soh
    WHERE soh.CustomerID = c.CustomerID
    AND soh.TotalDue > 5000
);