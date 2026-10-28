# Deux DataFrames de départ (volontairement proches de la logique SQL — ventes + produits à relier) :

import pandas as pd

ventes = pd.DataFrame({
    "produit_id": [1, 2, 1, 3, 2, 1],
    "date": ["2024-01-10", "2024-01-15", "2024-02-02", "2024-02-10", "2024-02-20", "2024-03-01"],
    "quantite": [2, 1, 3, 1, 2, 5]
})

produits = pd.DataFrame({
    "produit_id": [1, 2, 3],
    "nom": ["velo", "voiture", "basse"],
    "prix": [30, 6000, 3500]
})

#Rappel de syntaxe

pd.merge(df1, df2, on="cle_commune")           # équivalent JOIN
df.groupby("colonne")["autre_col"].sum()       # équivalent GROUP BY + SUM
df.groupby("colonne").agg({"col1": "sum", "col2": "count"})  # plusieurs agrégations
df.pivot_table(index="ligne", columns="colonne", values="valeur", aggfunc="sum")
df.melt(id_vars=["colonne_fixe"], var_name="nom_var", value_name="valeur")

#Exo 1
ventes_produits = pd.merge(ventes,produits,on ="produit_id")

#Exo 2
ventes_produits.groupby("nom")["quantite"].sum()

#Exo 3
ventes_produits.groupby("nom").agg({"quantite": ["sum", "count"]}) #en une seule ligne

 #plus lisible en nommant les colonnes
ventes_produits.groupby("nom").agg(                    
            quantite_total = ("quantite", "sum"),
            nombre_ventes = ("quantite", "count")
        )

#Exo 4
ventes_produits["CA"] = ventes_produits["quantite"] * ventes_produits["prix"] #création de la nouvelle colonne CA
ventes_produits.groupby("nom").sum() #calcul du total CA par produit

#Exo 5
ventes_produits["date"] = pd.to_datetime(ventes_produits["date"]) #conversion colonne date en datetime
ventes_produits["mois"] = ventes_produits["date"].dt.month #création de la nouvelle colonne mois

ventes_produits.pivot_table(index = "nom", columns = "mois", values = "quantite", aggfunc = "sum")

#Exo 6
df = ventes_produits.pivot_table(index = "nom", columns = "mois", values = "quantite", aggfunc = "sum")
df = df.reset_index() #reset_index() remet l’index actuel du DataFrame sous forme de colonne normale, et le remplace par un nouvel index par défaut (0, 1, 2...).
df.melt(id_vars=["nom"], var_name="mois", value_name="quantite")