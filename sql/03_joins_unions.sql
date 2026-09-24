## Exo 1 
SELECT COUNT(*)
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer sc
	on soh.CustomerID = sc.CustomerID;

SELECT COUNT(*)
FROM Sales.SalesOrderHeader 

-- Résultat : 31465

## Exo 2

SELECT COUNT(*) as Nb_produits_non_vendus
FROM Production.Product pp
LEFT JOIN Sales.SalesOrderDetail sod
	ON pp.ProductID = sod.ProductID
WHERE SalesOrderID is NULL

-- Résultat : 238

## Exo 3
-- Le nombre de ligne du résultat est identique au nombre de produits car nous avons une photo par produit.
-- Etape 1 : Vérifier le nombre de ligne sur chaque table
SELECT 
	(
	SELECT COUNT (ProductID)
	FROM Production.Product) AS nb_produits_p,
	COUNT (ProductID) AS nb_produits_ppp

FROM Production.ProductProductPhoto

-- Etape 2 : Vérifier s'il existe des doublons sur Product ID dans la table Production.ProductProductPhoto

SELECT
	ProductID,
	COUNT(ProductID) 
FROM Production.ProductProductPhoto
GROUP BY ProductID
HAVING COUNT(ProductID) > 1

-- Aucune ProductID n'est doublé sur la table Production.ProductProductPhoto

## Exo 4

-- Avec UNION (élimine les doublons)
SELECT Name FROM Production.Product
UNION
SELECT Name FROM Production.ProductCategory;

-- Avec UNION ALL (garde tout, y compris doublons)
SELECT Name FROM Production.Product
UNION ALL
SELECT Name FROM Production.ProductCategory;

-- Pour vérifier si doublon ou pas :
SELECT COUNT(*) AS Total_UNION
FROM (
    SELECT Name FROM Production.Product
    UNION
    SELECT Name FROM Production.ProductCategory
) AS Combine;

SELECT COUNT(*) AS Total_UNION_ALL
FROM (
    SELECT Name FROM Production.Product
    UNION ALL
    SELECT Name FROM Production.ProductCategory
) AS Combine;
