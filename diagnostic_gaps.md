# Diagnostic — Journal des blocages

<!-- #region J2 - Diagnostic SQL -->

<details>
<summary><h2>J2 - Diagnostic SQL</summary>

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

<!-- #endregion -->

<!-- #region J3 — Jointures et unions (cardinalités, doublons) -->

<details>
<summary><h2>J3 — Jointures et unions (cardinalités, doublons)</summary>

## Exercices

Objectif : maîtriser le piège le plus fréquent des jointures — les doublons provoqués par une mauvaise cardinalité — que l'exercice 6 de J2 n'a pas encore testé directement.

### Exercice 1 — INNER JOIN simple, vérifier le nombre de lignes

Jointe Sales.SalesOrderHeader et Sales.Customer. Compte le nombre total de lignes obtenues, et compare-le au nombre de lignes de SalesOrderHeader seule. Les deux comptes doivent être identiques — si ce n'est pas le cas, la jointure duplique des lignes. Vérifie pourquoi.

### Exercice 2 — LEFT JOIN et valeurs manquantes

Jointe Production.Product et Sales.SalesOrderDetail en LEFT JOIN, pour lister tous les produits, y compris ceux jamais vendus. Compte combien de produits n'ont aucune vente associée (colonne de la table de droite = NULL).

### Exercice 3 — Le piège des doublons volontaire

Jointe Production.Product avec Production.ProductProductPhoto (une table où un même produit peut avoir plusieurs photos). Observe : le nombre de lignes du résultat dépasse-t-il le nombre de produits ? Explique pourquoi en une phrase.

### Exercice 4 — UNION vs UNION ALL

Écris une requête qui liste dans un même résultat :

les Name des Production.Product
les Name des Production.ProductCategory

Teste d'abord avec UNION, puis avec UNION ALL. Si un nom de catégorie existe aussi comme nom de produit (improbable ici mais vérifie), quelle différence de résultat observes-tu entre les deux ?

Consigne : comme pour J2, écris tes tentatives, note les résultats et blocages dans diagnostic_gaps.md, on corrige ensemble ensuite.

<!-- #endregion -->


### Exercice 1 — INNER JOIN, vérification cardinalité
RAS
`COUNT(*)` identique avant/après jointure (31465) → cardinalité 1-vers-1 entre SalesOrderHeader et Customer, aucun doublon créé.

### Exercice 2 — LEFT JOIN, valeurs manquantes
RAS
238 produits sans aucune vente (`WHERE SalesOrderID IS NULL` après LEFT JOIN). Pattern à retenir : LEFT JOIN + IS NULL sur la clé de la table de droite = trouver les non-correspondances.

### Exercice 3 — Doublons via jointure 1-vers-plusieurs
**Blocage initial** : conclusion tirée avant d'avoir les vrais résultats — à toujours vérifier après exécution, jamais supposer.
**Blocage syntaxe** : tentative de tester deux conditions contradictoires (`COUNT < 1 AND COUNT > 1`) — impossible, aucune valeur ne peut satisfaire les deux à la fois.
**Résultat final** : aucun doublon de ProductID dans ProductProductPhoto (`HAVING COUNT > 1` → 0 ligne). Pour trouver les produits sans photo, nécessité de repartir de `Product` en LEFT JOIN (même logique que l'exercice 2), pas de la table photo elle-même.

### Exercice 4 — UNION vs UNION ALL
Non traité — confusion initiale entre UNION (empiler des colonnes similaires de deux tables) et JOIN (relier des tables sur une clé commune). Correction apportée avant résolution.