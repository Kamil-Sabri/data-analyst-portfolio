
-- Requête 1 : SELECT + WHERE

SELECT 
	ProductID,
	Name, 
	ListPrice
FROM Production.Product
WHERE ListPrice < 500
ORDER BY ListPrice DESC;

-- Requête 2 : GROUP BY + agrégation
SELECT
	CustomerID,
	COUNT(CustomerID) AS Nb_commandes
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY Nb_commandes DESC;

-- Requête 3 : HAVING 
SELECT
	CustomerID,
	COUNT(CustomerID) AS Nb_commandes
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(CustomerID) > 5
ORDER BY Nb_commandes DESC;

-- Requête 4 : CASE WHEN
SELECT
    ProductID,
    Name,
    ListPrice,
    CASE
        WHEN ListPrice < 100 THEN 'Bas'
        WHEN ListPrice BETWEEN 100 AND 500 THEN 'Moyen'
        WHEN ListPrice > 500 THEN 'Haut'
    END AS Categorie
FROM Production.Product;


-- Requête 5 : 
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '20230101' AND '20231231';

OU

SELECT *
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2023;

-- Requête 6 : Combinaison
USE AdventureWorks2025
SELECT
    pc.Name AS Categorie,
    YEAR(soh.OrderDate) AS Annee,
    MONTH(soh.OrderDate) AS Mois,
    SUM(sod.LineTotal) AS ChiffreAffaires
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name, YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY Annee, Mois, Categorie;
