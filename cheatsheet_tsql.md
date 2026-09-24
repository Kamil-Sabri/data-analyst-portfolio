## MySQL → T-SQL (pièges spécifiques)

| MySQL | T-SQL |
|---|---|
| `` `nom_colonne` `` (backticks) | `[nom_colonne]` ou rien si pas de mot réservé |
| `LIMIT 10 OFFSET 20` | `OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY` |
| `AUTO_INCREMENT` | `IDENTITY(1,1)` |
| `NOW()` | `GETDATE()` |
| `DATEDIFF(date1, date2)` — renvoie des jours, 2 arguments | `DATEDIFF(day, date2, date1)` — 3 arguments obligatoires |
| `STR_TO_DATE(str, format)` | `CONVERT(date, str, style)` ou `TRY_PARSE` |
| `DATE_FORMAT(d, format)` | `FORMAT(d, format)` |
| `GROUP_CONCAT(col SEPARATOR ',')` | `STRING_AGG(col, ',')` |
| `TRUE` / `FALSE` | `1` / `0` (type BIT) |
| `IFNULL` | `COALESCE` (identique à BigQuery) |

### Exemples pratiques
#### Backtricks → Crochets 
```sql

-- MySQL
SELECT `order`, 
        `customer name` 
FROM orders;

-- T-SQL
SELECT  [order], 
        [customer name] 
FROM orders;
```
#### LIMIT/OFFSET → OFFSET/FETCH 
```sql

-- MySQL
SELECT * 
FROM Sales.Customer
ORDER BY CustomerID
LIMIT 10 OFFSET 20;

-- T-SQL
SELECT * 
FROM Sales.Customer
ORDER BY CustomerID
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;
```

Rôle : découper un grand résultat en "pages", pour n'en afficher qu'une tranche à la fois.
Exemple — 10 clients d'AdventureWorks, en sautant les 20 premiers (page 3 si chaque page fait 10 lignes)

NB : Placer obligatoirement ORDER BY avant OFFSET

#### AUTO_INCREMENT → IDENTITY
```sql

-- MySQL
CREATE TABLE Clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR (100)
);

-- T-SQL
CREATE TABLE Clients (
    id INT IDENTITY (1,1) PRIMARY KEY,
    nom VARCHAR(100)
);
```

#### NOW () → GETDATE ()
```sql

-- MySQL
INSERT INTO Logs (message, date_creation) 
VALUES ('Connexion', NOW());

-- T-SQL
INSERT INTO Logs (message, date_creation) 
VALUES ('Connexion',GETDATE());
```  
Le rôle d'une table "Logs" : une table qui enregistre un historique d'événements — chaque ligne = une action qui s'est produite, avec la date/heure exacte. Utilisée pour tracer ce qui s'est passé (connexions, erreurs, actions utilisateur), pas pour stocker des données métier.

Décomposition de l'exemple :
INSERT INTO Logs → ajoute une nouvelle ligne dans la table Logs (message, date_creation) → précise dans quelles colonnes écrire
VALUES ('Connexion', NOW()) → les valeurs à insérer : le texte 'Connexion' dans la colonne message, et l'heure actuelle (via NOW()) dans la colonne 

**Résultat dans la table :**

| id | message | date_creation |
|---|---|---|
| 1 | Connexion | 2026-09-23 14:32:07 |


#### DATEDIFF → signature différente
```sql
-- MySQL (2 arguments, renvoie des jours)
SELECT DATEDIFF ('2024-03-15', '2024-01-01');
-- Résultat : 74

-- T-SQL (3 arguments, unité obligatoire)
SELECT DATEDIFF (day, '2024-01-01', '2024-03-15');
-- Résultat : 74

-- Exemple sur AdventureWorks, calculer le délai entre commande et livraison : 
SELECT DATEDIFF (day, 'OrderDate', 'ShipDate') AS DelaiLivraison
FROM Sales.SalesOrderHeader;

```
#### STR_TO_DATE → CONVERT/TRY_PARSE
```sql
-- MySQL
SELECT STR_TO_DATE('15/03/2024', '%d/%m/%Y');

-- T-SQL (avec code de style 103 = jour/mois/année)
SELECT CONVERT (date, '15/03/2024' , 103);
``` 
Rôle : transformer une chaîne de texte en vraie valeur de type date, exploitable pour trier, filtrer ou calculer des écarts.
Le code 103 est un identifiant de style prédéfini par T-SQL, qui indique dans quel ordre lire les composants de la date. Chaque nombre correspond à une convention régionale figée :

| Code| Format| Exemple
|---|---|---|
|101|mois/jour/année (US)|03/15/2024
|103|jour/mois/année (français/UK)|15/03/2024
|104|jour.mois.année (allemand)|15.03.2024
|111|année/mois/jour (japonais)|2024/03/15
|120|année-mois-jour heure:min:sec (ISO)|2024-03-15 14:30:00

```sql
-- ou plus lisible
SELECT TRY_PARSE ('15/03/2024' AS date USING 'fr-FR');
```
TRY_PARSE a un avantage : si la conversion échoue (texte invalide), il renvoie NULL au lieu de stopper la requête avec une erreur — utile pour nettoyer un jeu de données comportant des valeurs de date mal formatées


#### DATE_FORMAT → FORMAT
```sql
-- MySQL
SELECT DATE_FORMAT (NOW (), '%d %M %Y');
-- Résultat : "15 March 2024"

-- T-SQL
SELECT FORMAT (GETDATE(), 'dd MMMM yyyy');
-- Résultat : "15 March 2024"
```

Point d'attention : en T-SQL il faut toujours ajouter le troisième argument de locale ('fr-FR') si on souhaite obtenir les noms de mois en français — sans lui, FORMAT affiche par défaut en anglais ("23 September 2026") selon la configuration du serveur.

| Élément affiché | MySQL (`DATE_FORMAT`) | T-SQL (`FORMAT`) |
|---|---|---|
| Année sur 4 chiffres | `%Y` | `yyyy` |
| Année sur 2 chiffres | `%y` | `yy` |
| Mois en chiffres (01-12) | `%m` | `MM` |
| Mois en toutes lettres | `%M` | `MMMM` |
| Mois abrégé | `%b` | `MMM` |
| Jour du mois (01-31) | `%d` | `dd` |
| Jour de la semaine en lettres | `%W` | `dddd` |
| Heure (24h) | `%H` | `HH` |
| Minutes | `%i` | `mm` |
| Secondes | `%s` | `ss` |

#### GROUP_CONTACT → STRING_AGG
```sql
-- MySQL
SELECT CustomerID, GROUP_CONCAT(ProductName SEPARATOR ' , ') AS Produits
FROM Orders
GROUP BY CustomerID;

-- T-SQL
SELECT CustomerID, STRING_AGG (ProductName, ' , ') AS Produits
FROM Orders
GROUP BY CustomerID;

-- Résultat attendu pour un client : Produits = "Vélo route, Casque, Gants"
```
#### TRUSE/FALSE → 1/0
```sql
-- MySQL
SELECT *
FROM Produits
WHERE actif = TRUE;

-- T-SQL
SELECT *
FROM Produits
WHERE actif = 1;
```

#### IFNULL → COALESCE
```sql

-- MySQL
SELECT
    nom,
    IFNULL (remise, 0) AS remise_appliquee
FROM Produits;

-- T-SQL
SELECT 
    nom,
    COALESCE (remise, 0) AS remise_appliquee
FROM Produits;

-- Cas d'usage : afficher 0 au lieu de NULL quand un produit n'a pas de remise, pour éviter des erreurs dans un calcul en aval
```

## Format de date sûr en T-SQL

**Piège** : écrire une date littérale avec tirets (`'2013-01-01'`) dépend des paramètres régionaux du serveur/session. Selon la configuration (français vs anglais), T-SQL peut mal interpréter l'ordre jour/mois, provoquant soit une erreur de conversion, soit pire, une inversion silencieuse sans erreur visible.

**Solution** : toujours utiliser le format `YYYYMMDD`, sans séparateurs — le seul format garanti sans ambiguïté, quels que soient les paramètres régionaux.

```sql
-- Risqué (dépend des paramètres régionaux)
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31'

-- Sûr (format universel)
WHERE OrderDate BETWEEN '20130101' AND '20131231'
```

**Réflexe à avoir** : avant de filtrer sur une période précise, vérifier la plage de dates réelle d'une table plutôt que de supposer une année.

```sql
SELECT MIN(OrderDate) AS DatePlusAncienne, MAX(OrderDate) AS DatePlusRecente
FROM Sales.SalesOrderHeader;
```

### JOIN ... USING → pas d'équivalent, toujours écrire ON complet

MySQL permet de raccourcir une jointure quand les deux colonnes portent le même nom :
```sql
-- MySQL
JOIN Sales.SalesOrderHeader USING (SalesOrderID)
```

T-SQL n'a pas d'équivalent à `USING`. Toujours écrire la forme complète :
```sql
-- T-SQL
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
```