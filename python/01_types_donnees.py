# Exo 1

x = 10
y = 2.5
z = "Hello"
w = True

print(type(x))  # int
print(type(y))  # float
print(type(z))  # str
print(type(w))  # bool

# Exo 2
int("42")
float("42")
int(str("quarante-deux")) #erreur

# Exo 3
## Pour la liste
list = [1, 2, 3]
print (list)

## Pour le tuple
tuple = (1,2,3)
print (tuple)

# Exo 4
produit = {'nom':'marlow',
            'prix': 35,
            'categorie':'media'}
produit

# Exo 5

###Création des listes
a = ['Jack', 'Paul', 'Jack', 'Michel']
b = ['Jack', 'Christine', 'Michel', 'Christine']

###Conversion en set et supression des doublons
 set_a = set(a)
 set_b = set(b) 

##Operateurs sur les sets
set_a & set_b # Intersection (éléments présents dans les deux ensembles)
### Résultat : {'Jack', 'Michel'}

set_a | set_b # Union (éléments présents dans l'un ou l'autre ensemble)
### Résultat : {'Jack', 'Paul', 'Christine', 'Michel'}

set_a - set_b # Différence (éléments présents dans set_a mais pas dans set_b)
### Résultat : {'Paul'}

set_b - set_a # Différence (éléments présents dans set_b mais pas dans set_a)
### Résultat : {'Christine'}

# Exo 6
a = ['Jack', 'Paul', 'Michel']
print(a)
###Création de la liste

b=a
b.append('Lucile')

print(b)
###Ajout de 'Lucile' à la liste b
###Résultat : ['Jack', 'Paul', 'Michel', 'Lucile']