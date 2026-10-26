## Partie 1
### Exo 1 

CREATE VIEW vw_VentesParClient AS
SELECT 
	CustomerID,
	SUM(TotalDue) AS Total_Due
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

### Exo 2 
WITH Top_10_Clients AS (
	SELECT 
		TOP 10 CustomerID,
		SUM(TotalDue) AS Total_Due
	FROM Sales.SalesOrderHeader
	GROUP BY CustomerID
	ORDER BY Total_Due DESC
)

### Exo 3

SELECT 
	TOP 10 soh.CustomerID,
	SUM (sod.LineTotal) as total_depenses
INTO #VentesTop10
FROM sales.SalesOrderDetail sod
JOIN sales.SalesOrderHeader soh
ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID
ORDER BY total_depenses DESC


## Partie 2

### Exo 1 
SELECT *
FROM Production.product
WHERE ListPrice > 1000

### Exo 2 
SELECT 
	CustomerID,
	COUNT(SalesOrderID) AS nb_commandes
FROM sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID)  > 3
ORDER BY nb_commandes DESC

### Exo 3
SELECT 
	pp.Name,
	SUM(sod.OrderQty) AS total_qty
FROM Sales.SalesOrderDetail sod
JOIN Production.Product pp
ON sod.ProductID = pp.ProductID
GROUP BY pp.Name 
ORDER BY total_qty DESC

### Exo 4
SELECT sc.CustomerID
FROM Sales.Customer sc
LEFT JOIN Sales.SalesOrderHeader soh
ON sc.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID is NULL

### Exo 5
SELECT 
	ROW_NUMBER () OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS classement,
	OrderDate,
	CustomerID
FROM Sales.SalesOrderHeader

### Exo 6
SELECT 
	pc.ProductCategoryID,
	SUM(sod.LineTotal) as Total
FROM Production.ProductCategory pc
JOIN Production.ProductSubcategory psc
	ON pc.ProductCategoryID = psc.ProductCategoryID

JOIN Production.Product pp
	ON psc.ProductSubcategoryID = pp.ProductSubcategoryID

JOIN Sales.SalesOrderDetail sod
	ON pp.ProductID = sod.ProductID

GROUP BY pc.ProductCategoryID
HAVING SUM(sod.LineTotal) > 1000000

### Exo 7 
WITH commandes AS (
	SELECT
		CustomerID,
		SalesOrderID,
		OrderDate,
		LAG(OrderDate,1) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS Date_commande_prec
	FROM Sales.SalesOrderHeader
	)

SELECT
	CustomerID,
	SalesOrderID,
	OrderDate,
	DATEDIFF(day,Date_commande_prec,OrderDate) AS Ecart_jours

FROM commandes
ORDER BY CustomerID ASC, OrderDate ASC


### Exo 8 
WITH produits AS (
	SELECT 
		pp.ProductID,
		pc.ProductCategoryID,
		SUM(sod.UnitPrice) as prix

	FROM Production.ProductCategory pc
	JOIN Production.ProductSubcategory psc
		ON pc.ProductCategoryID = psc.ProductCategoryID
	JOIN Production.Product pp
		ON psc.ProductSubcategoryID = pp.ProductSubcategoryID
	JOIN Sales.SalesOrderDetail sod
		ON pp.ProductID = sod.ProductID
	GROUP BY pp.ProductID, pc.ProductCategoryID
		),
classement AS (
	SELECT 
		ProductCategoryID,
		ProductID,
		Prix,
		RANK () OVER (PARTITION BY ProductCategoryID ORDER BY prix DESC) AS rang
	FROM produits
	)
SELECT *
FROM classement
WHERE rang <=5
ORDER BY ProductCategoryID

### Exo 9
SELECT 
	TOP 5 CustomerID,
	COUNT (SalesOrderID) as total_commandes
INTO #ClientsTop5
FROM sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY total_commandes DESC

###Exo 10
SELECT 
	CustomerID,
	DATENAME(month,OrderDate) AS Mois,
	YEAR(Orderdate) AS Annee,
	COUNT(SalesOrderID) AS nombre_commandes
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, DATENAME(month,OrderDate), YEAR(OrderDate)
ORDER BY CustomerID, Annee, MONTH(OrderDate)