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
#### Backtricks > Crochets 
```sql
-- MySQL
SELECT `order`, `customer name` FROM orders;
-- T-SQL
SELECT [order], [customer name] FROM orders;
```
