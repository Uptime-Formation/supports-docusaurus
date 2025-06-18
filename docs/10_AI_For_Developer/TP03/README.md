# TP03 - Convertisseur Excel vers HTML

## Description

Ce projet convertit un fichier Excel (.xlsx) en un fichier HTML. Le code Python utilise la bibliothèque pandas pour lire les données du fichier Excel et génère une table HTML avec un style de base pour une meilleure lisibilité.

## Fonctionnalités

*   Lecture des fichiers Excel (.xlsx).
*   Conversion des données en un tableau HTML.
*   Gestion des fichiers Excel vides.
*   Gestion des erreurs et affichage des messages d'erreur.

## Prérequis

*   Python 3.x
*   Bibliothèques Python:
    *   pandas
    *   openpyxl

## Comment exécuter

1.  **Installation des dépendances:**

    ```bash
    pip install pandas openpyxl
    ```

2.  **Placer le fichier Excel:** Placez votre fichier Excel (par exemple, `doc.xlsx`) dans le même répertoire que le script Python (`script.py`).

3.  **Exécution du script:** Exécutez le script Python.

    ```bash
    python script.py
    ```

4.  **Résultat:** Le script générera un fichier HTML (par exemple, `doc_output.html`) dans le même répertoire, contenant le tableau HTML avec les données de votre fichier Excel.

## Structure du projet

*   `script.py`: Le script Python principal qui contient la logique de conversion.
*   `doc.xlsx`: Exemple de fichier Excel (à fournir).
*   `doc_output.html`: Fichier HTML généré.

## Notes

*   Le script utilise la bibliothèque `openpyxl` pour lire les fichiers Excel.
*   Les erreurs sont gérées et affichées dans le fichier HTML généré.
*   Le style HTML est basique, vous pouvez l'améliorer dans le code.

