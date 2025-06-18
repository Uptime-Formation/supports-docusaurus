# -*- coding: utf-8 -*-
import pandas as pd
import os
from typing import Union

# Step 2: Extract HTML template into a constant for better readability.
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tableau Excel</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        table {{ border-collapse: collapse; width: 100%; margin-top: 20px; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <h2>Données du fichier Excel</h2>
    {html_table_content}
</body>
</html>
"""

# Step 3: Add docstrings and type hints.
# Step 1: Improve error handling.
def excel_to_html_table(file_path: str) -> str:
    """
    Convertit un fichier Excel en un fichier HTML contenant une table.

    Args:
        file_path (str): Le chemin d'accès au fichier Excel à convertir.

    Returns:
        str: Le chemin d'accès au fichier HTML généré en cas de succès,
             ou une chaîne HTML contenant un message d'erreur en cas d'échec.
    """
    try:
        # Load Excel file
        df = pd.read_excel(file_path, engine='openpyxl')
        
        # Handle empty files
        if df.empty:
            return "<html><body><p>Le fichier Excel est vide</p></body></html>"

        html_table_content = df.to_html(index=False, classes='table table-striped')

        html_content = HTML_TEMPLATE.format(html_table_content=html_table_content)

        output_html_path = os.path.splitext(file_path)[0] + "_output.html"
        
        # Save HTML file
        with open(output_html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
            
        return output_html_path
    
    except FileNotFoundError:
        return f"<html><body><p>Erreur : Le fichier '{file_path}' n'a pas été trouvé.</p></body></html>"
    except pd.errors.EmptyDataError:
        return f"<html><body><p>Erreur : Le fichier Excel '{file_path}' est vide ou mal formé.</p></body></html>"
    except Exception as e: # Catch any other unexpected errors
        return f"<html><body><p>Erreur inattendue lors de la conversion : {str(e)}</p></body></html>"

# Execute the function with the Excel file
if __name__ == "__main__":
    excel_file = "doc.xlsx"  # File should be in the current working directory
    output_file = excel_to_html_table(excel_file)
    
    # Check if the output is a file path or an error message
    if output_file.startswith("<html>"):
        print("Une erreur est survenue lors de la conversion :")
        print(output_file) # Print the HTML error message
    else:
        print(f"Le fichier HTML a été créé : {output_file}")