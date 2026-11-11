Exo 1

WITH table_a AS (
		SELECT
				SUM(CASE WHEN OrderDate IS NOT NULL THEN 1 END) AS nb_order, --Calculer sur l'ensemble des colonnes le nombre de cellule non vide
				SUM(CASE WHEN DueDate IS NOT NULL THEN 1 END) nb_due,
				SUM(CASE WHEN ShipDate IS NOT NULL THEN 1 END) nb_ship,
				SUM(CASE WHEN CreditCardApprovalCode IS NOT NULL THEN 1 END) nb_credit
		FROM Sales.SalesOrderHeader
		)
SELECT 
	CAST(nb_due AS FLOAT) / nb_order * 100 AS order_to_due, -- N+1/N * 100 pour calculer le taux de conversion
	CAST(nb_ship AS FLOAT)/nb_due*100 AS due_to_ship,
	CAST(nb_credit AS FLOAT) /nb_ship * 100 AS ship_to_credit

FROM table_a

-- Rappel : CAST(valeur AS type) convertit explicitement une valeur d’un type de données vers un autre (ex. entier → décimal, texte → date).
-- Syntaxe : CAST(expression AS type_cible)
-- Exemples courants :
	-- CAST(nb_due AS FLOAT) → entier vers décimal (évite la troncature vue juste avant)
	-- CAST('2022-01-01' AS DATE) → texte vers date
	-- CAST(prix AS INT) → décimal vers entier (tronque, n’arrondit pas)

#Exo 2

WITH list_cmd AS (
		SELECT
			COUNT(PurchaseOrderID) as nb_cmd_cree,
			SUM(CASE WHEN Status >= 2 THEN 1 END) as approuvee,
			SUM(CASE WHEN Status = 4 THEN 1 END) as completee
		FROM Purchasing.PurchaseOrderHeader
		)
SELECT 
	(CAST(nb_cmd_cree AS FLOAT)/nb_cmd_cree)*100 AS pc_cmd_cree,
	(CAST(approuvee AS FLOAT)/nb_cmd_cree) * 100 AS pc_cmd_approuve,
	(CAST(completee AS FLOAT)/approuvee) *100 AS pc_cmd_completee
FROM list_cmd