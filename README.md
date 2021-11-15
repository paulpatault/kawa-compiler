# Kawa

Compilateur optimisant du langage Kawa (langage objet type Java) vers l'assembleur MIPS.

## Usage

+ Installation :
    ```bash
    $ git clone https://github.com/paulpatault/Kawa.git
    $ cd Kawa
    $ make
    ```
+ Exécution :
  + Pour commencer, compiler le fichier kawa :
    ```bash
    $ make compile file=<nom_du_fichier.kawa>
    ```
  + Puis éventuellement, exécuter le fichier asm généré : (nécessite le fichier `Mars4_5.jar` dans le dossier)
    ```bash
    $ make run file=<nom_du_fichier.asm>
    ```
+ Rangement:
    Suppression de l'exécutable et du dossier `_build`
    ```bash
    $ make clean
    ```
    Même chose que `make clean`, avec en plus une suppression des fichiers générés par une exécution
    ```bash
    $ make cleanall
    ```

## Organisation du code
Le code est contenu dans le dossier `src/` et séparé en nombreux sous dossiers.
Vous retrouverez donc :
- `ast/` : contient l'ensemble des fichiers `kawa.ml`, `pimp.ml`, ...
- `kawadir/` : contient le lexer, parser et type\_checker pour un fichier `.kawa`.
- `optim/` : contient les fichiers utiles pour le phase de compilation optimisée.
- `printer/` : contient les pretty-printers de chaque `ast`.
- `trads/` : contient les fichiers `kawa2pimp.ml`, plus généralement tous les `x2y.ml`.
- `utils/` : contient des fichiers implémentant un certain nombre de fonctions/exceptions/...
  utiles pour l'ensemble du projet.

## Organisation des tests
Les tests sont contenus dans le dossier `tests/` et séparé en deux sous dossiers.
Vous y retrouverez :
- `fonctionnels/` : contient de nombreux fichiers d'exemple qui sont bien compilé depuis
  le langage `kawa` vers l'assembleur `mips`.
- `errors/` : contient différents fichiers donnant différents exemples d'erreurs.
  Aucun de ceux-ci ne passe à la compilation.

## Travail réalisé
### Travail proposé
- Compilation des classes :
  - Les descripteurs sont enregistrés statiquement dans `.data`.
  - Les objets sont alloués sur le tas.
- Gestion de l'héritage :
  - héritage simple : ...
  - extension des attributs : ...
  - extension des méthodes : ...
  - surcharches des méthodes : ...
- Vérification du typage avant la compilation :
  - Vous retrouverez l'appel à `Kawa.type_checker.typ_prog` dans le main de `kawac.ml`.
  Cette procédure à pour fonction de vérifier le bon typage et la cohérence du programme `kawa`.
  Ainsi, si le programme est incohérent ou mal typé, une exception accompagnée un message d'erreur
  précis indiquant la cause de l'erreur ainsi que sa localisation dans le code.

### Modifications personnels
- Ajout de la possibilité d'imprimer des caratères (attention : il ne s'agit pas de strings)
  avec la procédure `putchar('c')`.
- Extension de la syntaxe de Kawa :
  - Ajout des opérateurs : `<=`, `>`, `>=`, `!=`, `&&`, `||`
  - Annotations dans le code : tags (à écrire juste avant une déclaration de méthode)
    - Syntaxe : `@{tag_name_1, …, tag_name_n}`
    - Tag `not_optim` : rend impossible la suppression de la fonction lors de l'optimisation des appels
    - Tag `static` : todo
- Interdiction pour les variables de commencer par une majuscule, mais les classes le peuvent.

## Remarques
- Les modifications apportées ne rendent plus fonctionnel l'interprète fourni.
- Les effets de bords ne sont pas "reconnus" par le calcul de liveness. J'ai du retirer le cas `Call`
  dans le fichier `optim/deadwriteelimination.ml` car ce cas effaçait certains appels de méthodes
  en trop.
