<summary><h2>import pandas as pd</h2></summary>

import pandas as pd

product = pd.read_csv("data/Product.csv")
subcategory = pd.read_csv("data/ProductSubcategory.csv")
category = pd.read_csv("data/ProductCategory.csv")
header = pd.read_csv("data/SalesOrderHeader.csv")
detail = pd.read_csv("data/SalesOrderDetail.csv")

<summary><h2>Exo 1</h2></summary>
product.loc[product["ListPrice"] > 1000].sort_values(by="ListPrice", ascending = False)

<summary><h2>Exo 2</h2></summary>
print(header.columns) #pour checker toutes les colonnes du Dataframe

df = header.groupby("CustomerID")["SalesOrderID"].count()
df[df > 3]

<summary><h2>Exo 3</h2></summary>
## Part 1 : Création de la table ventes en fusionnant detail et product sur la colonne ProductID.
ventes=pd.merge(detail,product, on="ProductID") #Utiliser obligatoirement le pd. avant merge() pour que ça fonctionne.
### Autre possibilité : 
ventes = detail.merge(product, on ="ProductID")

## Part 2
ventes.groupby("Name")["OrderQty"].sum().sort_values(ascending=False) 

<summary><h2>Exo 4</h2></summary>
customer_sales[customer_sales["SalesOrderID"].isna()]
### La partie intérieure généère les true/false, et la partie extérieure filtre le résultat

<summary><h2>Exo 5</h2></summary>

header_trie = header.sort_values(["CustomerID", "OrderDate"]) #etape 1 : trier le dataframe par CustomerID puis par OrderDate
header_trie["classement"] = header_trie.groupby("CustomerID").cumcount() + 1 #etape 2 : création du classement par CustomerID, en ajoutant 1 pour que le classement commence à 1 et non 0

header_trie[["classement","OrderDate","CustomerID"]] #etape 3 : affichage des colonnes classement, OrderDate et CustomerID pour vérifier que le classement est correct.

<summary><h2>Exo 6</h2></summary>

## Etape 1 : Checker d'abord l'ensemble des colonnes (nomdetable.columns) pour identifier les colonnes à utiliser pour le merge.

##Etape 2 : Fusions
cat = category[["ProductCategoryID", "Name"]]
subcat = subcategory[["ProductSubcategoryID", "ProductCategoryID"]]
prod = product[["ProductID", "ProductSubcategoryID"]]
det = detail[["ProductID", "LineTotal"]]

## Etape 3 : Fusionner les tables entre elles pour obtenir une table finale avec les colonnes ProductCategoryID, ProductSubcategoryID, ProductID et LineTotal.
produit_detail = prod.merge(det,on="ProductID").merge(subcat,on="ProductSubcategoryID").merge(cat,on="ProductCategoryID")

## Etape 4 : Grouper par ProductCategoryID et sommer les LineTotal pour obtenir le chiffre d'affaire par catégorie de produit.
df_produit_detail = produit_detail.groupby("Name")["LineTotal"].sum()

## Etape 5 : Afficher le résultat final.
ventes_par_produit = df_produit_detail[df_produit_detail>1000000]
ventes_par_produit
    ## NB : Script hypothétique avec une colonne supplémentaire (PrixHT)
df_produit_detail = produit_detail.groupby("Name")[["LineTotal", "PrixHT"]].sum()
ventes_par_produit = df_produit_detail[df_produit_detail["LineTotal"] > 1000000]
# Explication : [["LineTotal", "PrixHT"]] avec double crochet (liste de colonnes) force pandas à renvoyer un DataFrame, même si une seule colonne était sélectionnée — alors que ["LineTotal"] avec simple crochet (un seul nom) renvoie une Series. C’est ce choix de syntaxe, pas le groupby lui-même, qui détermine si tu dois ensuite référencer df["LineTotal"] ou filtrer directement sur df.

<summary><h2>Exo 7</h2></summary>

#Etape 1 : Créer un DF avec colonnes CustomerID et OrderDate
orders = header.sort_values(["CustomerID","OrderDate"]) #le tri du plus ancien au plus récent se fait automatiquement ici. Dans le cas contraire il aurait fallu écrire le script suivant orders = header.sort_values(["CustomerID","OrderDate"],ascending=[True,False])

#Etape 2 : Créer une colonne lag (dernière date de commande) pour chaque CustomerID
orders["lag"] = orders.groupby("CustomerID")["OrderDate"].shift(1)

#Etape 3 : Créer une colonne diff (différence entre la date de commande et la dernière date de commande) pour chaque CustomerID
orders["days"] = (orders["OrderDate"] - orders["lag"]).dt.days #soustraction d'abord entre deux colonnes et compléter avec dt.days

#Etape 4 : Créer un DF avec les colonnes CustomerID,OrderDate,lag et days
orders [["CustomerID","OrderDate","lag","days"]] 

<summary><h2>Exo 8</h2></summary>

#Etape 1 : Créer un DF avec colonnes ProductCategoryID et LineTotal trié par ProductCategoryID et LineTotal (du plus grand au plus petit)
prod_cat = produit_detail[["ProductCategoryID","LineTotal"]].copy().sort_values(["ProductCategoryID","LineTotal"],ascending=[True, False])

#Etape 2 : Créer une colonne rank (classement du chiffre d'affaire par catégorie de produit) pour chaque ProductCategoryID~
prod_cat["rank"] = prod_cat.groupby("ProductCategoryID")["LineTotal"].rank(method="min",ascending = False)
## Rappel : 
    # method="min" → équivalent RANK() (laisse des trous en cas d’égalité : 1,1,3)
    # method="dense" → équivalent DENSE_RANK() (pas de trous : 1,1,2)
    # method="first" → équivalent ROW_NUMBER() (ordre d’apparition, jamais d’égalité)

#Etape 3 : Top 5 des produits par catégorie de produit
prod_cat[prod_cat["rank"]<=5]

<summary><h2>Exo 9</h2></summary>

#Etape 1 : créer un DF avec colonnes CustomerID et SalesOrderID
cmd = header.groupby("CustomerID")["SalesOrderID"].count().reset_index(name="nb_cmd")
    ## NB : reset_index(name="nb_cmd") permet de renommer la colonne SalesOrderID en nb_cmd.  

#Etape 2 : créer une colonne rank (classement du nombre de commandes par client) pour chaque CustomerID
cmd ["rank"]= cmd["nb_cmd"].rank(method="min",ascending = False)

#Etape 3 : Trier la table par nombre de commandes décroissant et afficher les colonnes rank, CustomerID et nb_cmd
commandes = cmd[["rank","CustomerID","nb_cmd"]].sort_values("nb_cmd",ascending = False)

#Etape 4 : Top 5 des clients par nombre de commandes (du plus grand au plus petit)
commandes.head(5)

<summary><h2>Exo 10</h2></summary>

#Etape 1 : Créer les colonnes dans le DF initial
header["m_name"] = header["OrderDate"].dt.month_name()
header["m_nb"] = header["OrderDate"].dt.month
header["year"] = header["OrderDate"].dt.year
#Etape 2 : Grouper par mois et année, compter le nombre de commandes, puis nommer la colonne de nb_cmd
dt = header.groupby(["m_nb","year","m_name"])["SalesOrderID"].count().reset_index(name="nb_cmd")
#Etape 3 : Trier le DF par année puis par mois
dt = dt.sort_values(["year","m_nb"],ascending=[True,True])
#Etape 4 : Créer un DF avec les colonnes m_name, year et nb_cmd
commandes_par_mois=dt[["m_name","year","nb_cmd"]]

commandes_par_mois

#Autre manière d'écrire le code
header["periode"] = header["OrderDate"].dt.to_period("M") #to_period("M") trie déjà chronologiquement par nature (pas besoin de m_nb comme béquille pour le tri).
dt = header.groupby("periode")["SalesOrderID"].count().reset_index(name="nb_cmd") #Une seule colonne de regroupement au lieu de trois.
dt["m_name"] = dt["periode"].dt.strftime("%B") #.dt.strftime("%B") récupère le nom du mois en texte, uniquement pour l’affichage final.
dt = dt.sort_values("periode")
commandes_par_mois = dt[["m_name","nb_cmd"]]