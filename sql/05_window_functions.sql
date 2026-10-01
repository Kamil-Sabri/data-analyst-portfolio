## Réponses

### Exo 1

SELECT 
	CustomerID,
	OrderDate,
	ROW_NUMBER () OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS num_commande
FROM Sales.SalesOrderHeader

### Exo 2

WITH Ranking AS (
	SELECT 
		ProductID,
		Name,
		RANK() OVER (ORDER BY ListPrice ASC) AS Rang,
		DENSE_RANK() OVER (ORDER BY ListPrice ASC) AS RangDense
	FROM Production.Product
	)
SELECT *
FROM Ranking
WHERE Rang <> RangDense 

### Exo 3

SELECT
	CustomerID,
	SalesOrderID,
	OrderDate,
	LAG(OrderDate,1) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS Date_commande_prec
FROM Sales.SalesOrderHeader;

-- Déclinaison exo : Afficher sur chaque ligne combien de jours en moyenne met le CustomerID pour commander 

WITH Historique AS (
    SELECT
        CustomerID,
        SalesOrderID,
        OrderDate,
        LAG(OrderDate, 1) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS Date_commande_prec
    FROM Sales.SalesOrderHeader
),
Ecarts AS (
    SELECT
        CustomerID,
        SalesOrderID,
        OrderDate,
        Date_commande_prec,
        DATEDIFF(day, Date_commande_prec, OrderDate) AS Ecart_jours
    FROM Historique
)
SELECT
    CustomerID,
    SalesOrderID,
    OrderDate,
    Date_commande_prec,
    AVG(Ecart_jours) OVER (PARTITION BY CustomerID) AS Moyenne_jours_entre_achats
FROM Ecarts;

### Exo 4
SELECT
	CustomerID,
	SalesOrderID,
	OrderDate,
	LEAD(OrderDate,1) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS Date_commande_suivante
FROM Sales.SalesOrderHeader;

### Exo 5 

SELECT
	CustomerID,
	SalesOrderID,
	OrderDate,
	ROUND(TotalDue,2) AS Montant_commande,
	ROUND(
		SUM (TotalDue) OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC),
		2) AS Montant_cumul_commande
	
FROM Sales.SalesOrderHeader;