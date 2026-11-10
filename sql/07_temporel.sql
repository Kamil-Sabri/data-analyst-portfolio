# Exo 1
    # Méthode utilisée
WITH order_per_m AS (
	SELECT 
		FORMAT(OrderDate, 'yyyy-MM') AS date_m,
		ROUND(SUM(TotalDue),2) AS total_per_month
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate, 'yyyy-MM')
	),
orders AS (
	SELECT 
		date_m,
		total_per_month,
		LAG(total_per_month, 1) OVER (ORDER BY date_m ASC) AS last_m_total
	FROM order_per_m
	)
SELECT 
	date_m,
	total_per_month,
	last_m_total,
	(total_per_month - NULLIF(last_m_total,0)) / NULLIF(last_m_total,0) AS evol
FROM orders

    # Méthode alternative 
WITH order_per_m AS (
    SELECT 
        FORMAT(OrderDate, 'yyyy-MM') AS date_m,
        ROUND(SUM(TotalDue), 2) AS total_per_month
    FROM Sales.SalesOrderHeader
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT 
    date_m,
    total_per_month,
    LAG(total_per_month) OVER (ORDER BY date_m) AS last_m_total,
    (total_per_month - LAG(total_per_month) OVER (ORDER BY date_m))
        / NULLIF(LAG(total_per_month) OVER (ORDER BY date_m), 0) AS evol
FROM order_per_m

# Exo 2
SELECT 
	min(OrderDate),
	max(OrderDate)
FROM Sales.SalesOrderHeader;

SELECT
	DATEDIFF(month, min(OrderDate), max(OrderDate)) + 1
FROM Sales.SalesOrderHeader;

WITH order_per_m AS (
    SELECT FORMAT(OrderDate, 'yyyy-MM') AS date_m
    FROM Sales.SalesOrderHeader
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT COUNT(*) FROM order_per_m
    #Explication : 
    Le problème de départ

    LAG(total_per_month, 12) recule de 12 lignes, pas de 12 mois. Si un mois n’a aucune commande, il n’apparaît pas du tout dans order_per_m (le GROUP BY ne produit une ligne que pour les mois où il y a au moins une commande). Dans ce cas, la ligne 13 plus bas ne correspond plus au “même mois l’année d’avant”, mais au mois suivant — tout est décalé silencieusement, sans erreur SQL.

    La logique du contrôle : comparer un nombre attendu à un nombre réel

    Nombre de mois attendu : si la plage de dates va du 30/05/2022 au 29/06/2025, et qu’aucun mois n’est manquant, on doit trouver exactement un certain nombre de mois distincts entre ces deux bornes. On a calculé ce nombre avec DATEDIFF(month, min, max) + 1 → résultat : 38.
    DATEDIFF(month, ...) compte combien de “frontières de mois” sont franchies entre les deux dates.
    Le +1 sert à inclure le mois de départ lui-même (sinon on ne compterait que les mois franchis, pas le point de départ).
    Nombre de mois réellement présents : on reprend la même CTE qui agrège par mois (GROUP BY FORMAT(OrderDate,'yyyy-MM')), et on compte simplement le nombre de lignes obtenues avec COUNT(*) → résultat : 38 aussi.

    La conclusion

    Si les deux nombres (attendu vs réel) sont égaux, ça veut dire que chaque mois théorique de la plage a bien généré au moins une commande — donc aucune ligne ne manque dans order_per_m. C’est exactement ce qu’on a trouvé (38 = 38), ce qui confirme que LAG(..., 12) peut être utilisé sans risque de décalage silencieux.

    Si les deux nombres avaient été différents (ex: 38 attendu vs 35 réel), ça aurait signalé 3 mois sans aucune commande — et LAG(..., 12) aurait alors donné un résultat faux, sans lever d’erreur pour autant.

    # Solution : 
WITH order_per_m AS (
	SELECT 
		FORMAT(OrderDate, 'yyyy-MM') AS date_m,
		ROUND(SUM(TotalDue),2) AS total_per_month
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate, 'yyyy-MM')
	),
orders AS (
	SELECT 
		date_m,
		total_per_month,
		LAG(total_per_month, 12) OVER (ORDER BY date_m ASC) AS last_year_total
	FROM order_per_m
	)
SELECT 
	date_m,
	total_per_month,
	last_year_total,
	(total_per_month - NULLIF(last_year_total,0)) / NULLIF(last_year_total,0) AS evol
FROM orders

# Exo 3 
WITH ca_per_m AS (
	SELECT 
		FORMAT(OrderDate,'yyyy-MM') as date_m,
		ROUND(SUM(TotalDue),2) as total  #ne pas insérer un ORDER BY, celui de la moyenne en dessous suffit
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate,'yyyy-MM')
	)
SELECT 
	date_m,
	AVG(total) OVER (ORDER BY date_m ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_due
FROM ca_per_m

# Exo 4

WITH ca_per_m AS (
	SELECT 
		FORMAT(OrderDate,'yyyy-MM') as date_m,
		ROUND(SUM(TotalDue),2) as total
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate,'yyyy-MM')
	)
SELECT 
	date_m,
	AVG(total) OVER (ORDER BY date_m ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS avg_due
FROM ca_per_m

# Exo 5
WITH ca_per_m AS (
	SELECT 
		FORMAT(OrderDate,'yyyy-MM') as date_m,
		ROUND(SUM(TotalDue),2) as total
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate,'yyyy-MM')
	)
SELECT 
	date_m,
	SUM(total) OVER (PARTITION BY LEFT(date_m,4) ORDER BY date_m ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS total_per_year

FROM ca_per_m

    # Explication : 
    Ce qu’est une “fenêtre de calcul” (frame)

    Quand tu écris SUM(total) OVER (PARTITION BY ... ORDER BY ...), SQL doit savoir précisément quelles lignes additionner pour chaque ligne du résultat — “depuis le début de l’année jusqu’à cette ligne”, par exemple. Cette plage de lignes s’appelle la fenêtre, et elle peut être définie de deux façons différentes : ROWS ou RANGE.

    La différence entre les deux

    ROWS compte des lignes physiques : “la ligne d’avant”, “les 2 lignes d’avant”, etc. Simple comptage.
    RANGE compare des valeurs : il regroupe ensemble toutes les lignes qui ont la même valeur dans la colonne de tri (date_m ici), plutôt que de compter des lignes une par une.

    Pourquoi ton erreur apparaît

    Quand tu écris juste ORDER BY date_m ASC sans préciser ROWS ou RANGE, SQL Server choisit RANGE par défaut, silencieusement. Et RANGE a une contrainte technique : la colonne utilisée pour comparer les valeurs ne doit pas dépasser 900 octets. Le problème, c’est que FORMAT(OrderDate, 'yyyy-MM') produit un texte qui semble court (“2022-05”), mais son type de données interne (nvarchar) est beaucoup plus large que ça — d’où le dépassement, même si la valeur affichée est minuscule.

    La solution : forcer ROWS au lieu de RANGE

    Comme tu n’as pas besoin du comportement “regrouper les valeurs identiques” de RANGE (chaque mois est de toute façon unique), tu peux basculer sur ROWS, qui n’a pas cette limite de taille — même résultat, juste une méthode de calcul différente en interne.

    Où l’ajouter exactement dans ton script

# Exo 6
WITH ca_per_m AS (
	SELECT 
		FORMAT(OrderDate,'yyyy-MM') as date_m,
		ROUND(SUM(TotalDue),2) as total
	FROM Sales.SalesOrderHeader
	GROUP BY FORMAT(OrderDate,'yyyy-MM')
	)
SELECT 
	date_m,
	SUM(total) OVER (ORDER BY date_m ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS total_per_year

FROM ca_per_m