# Diagnostic — Journal des blocages

<details>
<summary>J2 - Diagnostic SQL</summary>

## Exercices

### Exercice 1 - SELECT + WHERE	
Lister les produits dont le prix (ListPrice) dépasse 500

### Exercice 2 — GROUP BY + agrégation
Compte le nombre de commandes par client, table Sales.SalesOrderHeader. Trie du client ayant le plus de commandes au moins.

### Exercice 3 — HAVING
À partir de l'exercice 2, ne garde que les clients ayant passé plus de 5 commandes.

### Exercice 4 — CASE WHEN
Sur Production.Product, catégorise chaque produit selon son ListPrice :

Bas : moins de 100
Moyen : entre 100 et 500
Haut : plus de 500

Affiche ProductID, Name, ListPrice et la catégorie calculée.

### Exercice 5 — Filtre sur date
Sur Sales.SalesOrderHeader, liste uniquement les commandes passées en 2023 (colonne OrderDate).

### Exercice 6 — Combinaison
Chiffre d'affaires mensuel par catégorie de produit. Tables nécessaires : Sales.SalesOrderDetail, Production.Product, Production.ProductSubcategory ou ProductCategory (à explorer), Sales.SalesOrderHeader pour la date.

## Requêtes

### Requête 1 — SELECT + WHERE

**Testée sans blocage.** Syntaxe identique à MySQL/BigQuery sur ce cas simple.

**Résultat :** 368 lignes (produits avec ListPrice > 500).

### Requête 4 — CASE WHEN

**Point d'attention métier** : de nombreux produits ont ListPrice = 0 (composants internes non vendus directement — vis, roulements, plaques). Ils tombent dans la catégorie "Bas", ce qui est correct techniquement mais fausserait une analyse de pricing si on ne filtre pas ces lignes en amont.

### Requête 5 — Filtre sur date

**Blocage rencontré :** `WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31'` a renvoyé une erreur :
`Msg 242 - La conversion d'un type de données varchar en type de données datetime a créé une valeur hors limites.`

**Cause :** le format de date avec tirets (`YYYY-MM-DD`) n'est pas universellement sûr en T-SQL. Son interprétation dépend des paramètres régionaux (langue/format) configurés sur la session ou le serveur — une session en français peut lire une date différemment d'une session en anglais, ce qui peut provoquer une erreur de conversion ou, pire, une inversion silencieuse jour/mois sans erreur visible.

**Solution :** utiliser le format `YYYYMMDD` sans séparateurs, qui est interprété de façon identique quels que soient les paramètres régionaux du serveur — le seul format de date littérale garanti sans ambiguïté en T-SQL.

```sql
-- Risqué (dépend des paramètres régionaux)
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31'

-- Sûr (format universel)
WHERE OrderDate BETWEEN '20130101' AND '20131231'
```

**Second blocage, indépendant du premier :** `YEAR(OrderDate) = 2013` ne renvoyait aucune ligne, sans erreur. Cause : AdventureWorks2025 ne couvre pas la même plage de dates que les anciennes versions (2014/2017). Vérification systématique à faire avant de filtrer sur une année précise :

```sql
SELECT MIN(OrderDate) AS DatePlusAncienne, MAX(OrderDate) AS DatePlusRecente
FROM Sales.SalesOrderHeader;
```

**Règle à retenir :** toujours écrire les dates littérales au format `YYYYMMDD`, et vérifier la plage de dates réelle d'une table avant de filtrer sur une période précise plutôt que de supposer l'année.

</details>