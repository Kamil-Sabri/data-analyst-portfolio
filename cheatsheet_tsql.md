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

-- ou plus lisible
SELECT TRY_PARSE ('15/03/2024' AS date USING 'fr-FR');

```
#### DATE_FORMAT → FORMAT
```sql
-- MySQL
SELECT DATE_FORMAT (NOW (), '%d %M %Y');
-- Résultat : "15 March 2024"

-- T-SQL
SELECT FORMAT (GETDATE(), 'dd MMMM yyyy');
-- Résultat : "15 March 2024"
``` 

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

