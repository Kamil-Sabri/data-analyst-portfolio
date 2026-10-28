#Dataset de départ 
import pandas as pd

data = {
    "nom": [" Vélo", "Voiture", "voiture", "Basse", "Phone", None],
    "prix": [30, 6000, 6000, None, 900, 150],
    "categorie": ["Mobilité", "mobilité ", "mobilité", "Musique", "Telecom", "Vêtements"],
    "date_achat": ["2024-01-15", "2024-02-20", "2024-02-20", "2024-03-05", None, "2024-04-10"],
    "stock": [4, 2, 2, 5, 10, 999]
}
df = pd.DataFrame(data)

#Rappel de syntaxe 
df.isna().sum()                          # compter les NaN par colonne
df.dropna()                              # supprimer les lignes avec NaN
df.fillna(valeur)                        # remplacer les NaN
df.duplicated()                          # détecter les doublons
df.drop_duplicates()                     # supprimer les doublons
df["col"].str.strip()                    # retirer espaces
df["col"].str.lower()                    # minuscules
pd.to_datetime(df["col"])                # convertir en date
df.describe()                            # statistiques descriptives (min, max, moyenne...)

# Exo 1
df.isna().sum()

# Exo 2
## Partie 1
df.dropna()

## Partie 2 
moyenne_prix = df["prix"].mean()
df["prix"] = df["prix"].fillna(moyenne_prix) # Pour remplacer les NaN par la moyenne de la colonne prix (sur 2 lignesss)

df["prix"] = df["prix"].fillna(df["prix"].mean()) # Pour remplacer les NaN par la moyenne de la colonne prix (sur 1 ligne)

# Exo 3
df.duplicated() # détecter les doublons
df.drop_duplicates() # supprimer les doublons

# Exo 4
df["nom"].str.strip().str.lower()
df["categorie"].str.strip().str.lower() #important : on peut enchainer str.strip et str.lower pour nettoyer les colonnes de texte. En revanche pas possible de mettre les deux colonnes sur la même ligne.

# Exo 5
df["date_achat"] = pd.to_datetime(df["date_achat"]) #penser a bien mettre df["date_achat"] = pour enregistrer la modification dans le dataframe. 

df["date_achat"].dt.month #penser a bien mettre .dt.month. ".dt" est un accesseur au même titre que .str pour les strings.

#Exo 6
df["stock"].describe #pour un descriptif de la colonne stock
df.loc[df["stock"] > 100] #Pour isoler la ligne contenant les stocks élevés