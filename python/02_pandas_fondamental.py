## Rappel syntaxe

import pandas as pd

df = pd.DataFrame({...})   # créer depuis un dictionnaire
df.shape                   # (lignes, colonnes)
df.dtypes                  # type de chaque colonne
df.iloc[0]                 # position (index numérique)
df.loc[0]                  # label (index nommé/numéroté)

# Exo 1
import pandas as pd

data = {  ## Créer le dictionnaire 
    "nom": ['velo', 'voiture', 'basse', 'phone', 'veste'],
    "prix": [30, 6000, 3500, 900, 150],
    "categorie": ['mobilité', 'mobilité', 'musique', 'telecom', 'vêtements'],
    "stock": [4, 2, 5, 10, 20]
        }

df= pd.DataFrame(data) ## Conversion du dictionnaire en DataFrame

print(df) ## Afficher le DataFrame

print(df.shape) ## Afficher le nombre de lignes et de colonnes du DataFrame

print(df.dtypes) # Afficher les types de chaque colonne du DataFrame

print(df.iloc[0]) ## Afficher la première ligne du DataFrame

print(df.loc[0]) ## Afficher le première ligne du DataFrame en utilisant l'index nommé


# Exo 2

df["prix"]              # une seule colonne → simple crochet, nom entre guillemets
df[["nom", "prix"]]     # plusieurs colonnes → double crochet, liste de noms

# Exo 3
df.iloc[:1]
df.iloc[:3]

# Exo 4
print(df.loc[2])          # ligne complète, index = 2 ("basse")
print(df.loc[2, "prix"])  # uniquement le prix de cette ligne → 3500

# Exo 5
df.loc[df["prix"] > 500]

# Exo 6
df.sort_values(by="prix", ascending=False)

