---
title: TP4 - Instructions API REST & Swagger
---

# Instructions pour TP4 : API REST avec Swagger

## Objectif

Ces instructions guident la création d'une API REST documentée avec OpenAPI/Swagger, en suivant l'approche **contract-first** (le contrat d'API définit le code, pas l'inverse).

---

## Partie 1 : OpenAPI / Swagger

### Qu'est-ce que OpenAPI ?

**OpenAPI** (anciennement Swagger) est une spécification standard pour décrire des APIs REST.

**Avantages** :
- ✅ Documentation interactive automatique
- ✅ Contrat partagé entre frontend/backend
- ✅ Validation automatique des requêtes/réponses
- ✅ Génération de code client/serveur

### Structure d'un fichier swagger.json

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Nom de l'API",
    "version": "1.0.0",
    "description": "Description de l'API"
  },
  "paths": {
    "/chemin": {
      "methode": {
        "summary": "Description courte",
        "requestBody": { ... },
        "responses": { ... }
      }
    }
  },
  "components": {
    "schemas": { ... }
  }
}
```

---

## Partie 2 : Spécification de l'API

### Fichier swagger.json complet

Créez `docs/swagger.json` :

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Sales Analysis API",
    "version": "1.0.0",
    "description": "API pour analyser des fichiers CSV de ventes e-commerce"
  },
  "servers": [
    {
      "url": "http://localhost:5000",
      "description": "Serveur de développement"
    }
  ],
  "paths": {
    "/api/analyze": {
      "post": {
        "summary": "Analyser un fichier CSV",
        "description": "Upload un fichier CSV de ventes et retourne les statistiques",
        "tags": ["Analysis"],
        "requestBody": {
          "required": true,
          "content": {
            "multipart/form-data": {
              "schema": {
                "type": "object",
                "properties": {
                  "file": {
                    "type": "string",
                    "format": "binary",
                    "description": "Fichier CSV à analyser"
                  }
                },
                "required": ["file"]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Analyse réussie",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AnalysisResult"
                }
              }
            }
          },
          "400": {
            "description": "Requête invalide (fichier manquant)",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            }
          },
          "422": {
            "description": "Format CSV invalide",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            }
          },
          "413": {
            "description": "Fichier trop volumineux (> 10 MB)",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            }
          }
        }
      }
    },
    "/api/stats": {
      "get": {
        "summary": "Obtenir les statistiques de la dernière analyse",
        "description": "Retourne les stats de la dernière analyse effectuée",
        "tags": ["Analysis"],
        "responses": {
          "200": {
            "description": "Statistiques disponibles",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/AnalysisResult"
                }
              }
            }
          },
          "404": {
            "description": "Aucune analyse disponible",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Error"
                }
              }
            }
          }
        }
      }
    },
    "/api/health": {
      "get": {
        "summary": "Vérifier l'état de l'API",
        "description": "Endpoint de healthcheck",
        "tags": ["System"],
        "responses": {
          "200": {
            "description": "API fonctionnelle",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "status": {
                      "type": "string",
                      "example": "healthy"
                    },
                    "version": {
                      "type": "string",
                      "example": "1.0.0"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "AnalysisResult": {
        "type": "object",
        "required": ["total", "top_products", "ca_by_city"],
        "properties": {
          "total": {
            "type": "number",
            "format": "float",
            "description": "Total des ventes en euros",
            "example": 3756.94
          },
          "top_products": {
            "type": "array",
            "description": "Top 3 des produits les plus vendus",
            "items": {
              "$ref": "#/components/schemas/Product"
            }
          },
          "ca_by_city": {
            "type": "object",
            "description": "Chiffre d'affaires par ville",
            "additionalProperties": {
              "type": "number",
              "format": "float"
            },
            "example": {
              "Paris": 2750.97,
              "Lyon": 925.49,
              "Marseille": 79.99
            }
          }
        }
      },
      "Product": {
        "type": "object",
        "required": ["name", "quantity"],
        "properties": {
          "name": {
            "type": "string",
            "description": "Nom du produit",
            "example": "Laptop"
          },
          "quantity": {
            "type": "integer",
            "description": "Quantité totale vendue",
            "example": 4
          }
        }
      },
      "Error": {
        "type": "object",
        "required": ["error"],
        "properties": {
          "error": {
            "type": "string",
            "description": "Message d'erreur",
            "example": "Invalid CSV format"
          },
          "details": {
            "type": "string",
            "description": "Détails supplémentaires sur l'erreur"
          }
        }
      }
    }
  }
}
```

---

## Partie 3 : Implémenter l'API

### Approche contract-first

1. **Écrire la spec Swagger** (fait ci-dessus)
2. **Générer les tests d'acceptance** depuis la spec
3. **Implémenter les endpoints** pour passer les tests
4. **Intégrer Swagger UI** pour la documentation

### Code de l'API (Flask)

```python
# src/api.py
from flask import Flask, request, jsonify
from flask_swagger_ui import get_swaggerui_blueprint
from werkzeug.utils import secure_filename
import csv
import io
from core import calculate_total, top_products, ca_by_city

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10 MB

# Configuration Swagger UI
SWAGGER_URL = '/docs'
API_URL = '/static/swagger.json'
swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "Sales Analysis API"}
)
app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

# Stockage temporaire (en production, utiliser une DB)
last_analysis = None

def load_csv_from_upload(file):
    """Charge un CSV depuis un upload"""
    content = file.read().decode('utf-8')
    lines = content.splitlines()
    reader = csv.DictReader(lines)
    return list(reader)

@app.route('/api/health', methods=['GET'])
def health():
    """Healthcheck endpoint"""
    return jsonify({
        'status': 'healthy',
        'version': '1.0.0'
    }), 200

@app.route('/api/analyze', methods=['POST'])
def analyze():
    """Analyse un fichier CSV uploadé"""
    global last_analysis

    # Validation de la requête
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']

    if not file.filename:
        return jsonify({'error': 'Empty filename'}), 400

    if not file.filename.endswith('.csv'):
        return jsonify({'error': 'Only CSV files allowed'}), 400

    try:
        # Charger et analyser
        data = load_csv_from_upload(file)

        if not data:
            return jsonify({'error': 'Empty CSV file'}), 422

        # Calculer les statistiques (réutilisation de core.py)
        result = {
            'total': round(calculate_total(data), 2),
            'top_products': top_products(data, 3),
            'ca_by_city': {
                city: round(amount, 2)
                for city, amount in ca_by_city(data).items()
            }
        }

        # Sauvegarder pour /api/stats
        last_analysis = result

        return jsonify(result), 200

    except KeyError as e:
        return jsonify({
            'error': 'Invalid CSV format',
            'details': f'Missing column: {str(e)}'
        }), 422

    except Exception as e:
        return jsonify({
            'error': 'Processing error',
            'details': str(e)
        }), 500

@app.route('/api/stats', methods=['GET'])
def stats():
    """Retourne les stats de la dernière analyse"""
    if last_analysis is None:
        return jsonify({'error': 'No analysis available'}), 404

    return jsonify(last_analysis), 200

# Servir le fichier swagger.json
@app.route('/static/swagger.json')
def swagger_spec():
    """Sert la spécification OpenAPI"""
    import json
    with open('docs/swagger.json', 'r') as f:
        spec = json.load(f)
    return jsonify(spec)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### Installation des dépendances

```bash
# Flask + Swagger UI
pip install flask flask-swagger-ui

# Créer requirements.txt
pip freeze > requirements.txt
```

---

## Partie 4 : Tests d'acceptance

### Fichier de tests curl

Créez `docs/api-acceptance-tests.md` :

```markdown
# Tests d'Acceptance API

## Prérequis
- Serveur lancé : `python src/api.py`
- Serveur accessible sur http://localhost:5000

## Test 1 : Healthcheck

**Commande** :
```bash
curl -X GET http://localhost:5000/api/health
```

**Résultat attendu** :
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

**Status code** : 200

---

## Test 2 : Analyse d'un CSV valide

**Commande** :
```bash
curl -X POST http://localhost:5000/api/analyze \
  -F "file=@data/sales.csv"
```

**Résultat attendu** :
```json
{
  "total": 3756.94,
  "top_products": [
    {"name": "Laptop", "quantity": 4},
    {"name": "Mouse", "quantity": 3},
    {"name": "Keyboard", "quantity": 1}
  ],
  "ca_by_city": {
    "Paris": 2750.97,
    "Lyon": 925.49,
    "Marseille": 79.99
  }
}
```

**Status code** : 200

---

## Test 3 : Obtenir les stats

**Commande** :
```bash
curl -X GET http://localhost:5000/api/stats
```

**Résultat attendu** : Mêmes données que Test 2

**Status code** : 200

---

## Test 4 : Stats sans analyse préalable

**Commande** :
```bash
# Redémarrer le serveur d'abord
curl -X GET http://localhost:5000/api/stats
```

**Résultat attendu** :
```json
{
  "error": "No analysis available"
}
```

**Status code** : 404

---

## Test 5 : Upload sans fichier

**Commande** :
```bash
curl -X POST http://localhost:5000/api/analyze
```

**Résultat attendu** :
```json
{
  "error": "No file provided"
}
```

**Status code** : 400

---

## Test 6 : Upload fichier non-CSV

**Commande** :
```bash
echo "not a csv" > /tmp/test.txt
curl -X POST http://localhost:5000/api/analyze \
  -F "file=@/tmp/test.txt"
```

**Résultat attendu** :
```json
{
  "error": "Only CSV files allowed"
}
```

**Status code** : 400

---

## Test 7 : CSV vide

**Commande** :
```bash
curl -X POST http://localhost:5000/api/analyze \
  -F "file=@data/sales_empty.csv"
```

**Résultat attendu** :
```json
{
  "error": "Empty CSV file"
}
```

**Status code** : 422

---

## Checklist des tests

- [ ] Test 1 : Healthcheck ✅
- [ ] Test 2 : Analyse valide ✅
- [ ] Test 3 : Stats disponibles ✅
- [ ] Test 4 : Stats non disponibles ✅
- [ ] Test 5 : Erreur 400 (no file) ✅
- [ ] Test 6 : Erreur 400 (wrong format) ✅
- [ ] Test 7 : Erreur 422 (empty CSV) ✅
```

---

## Partie 5 : Swagger UI

### Accéder à la documentation

Une fois le serveur lancé :

```bash
python src/api.py
```

Ouvrir dans le navigateur : **http://localhost:5000/docs**

Vous verrez :
- ✅ Liste de tous les endpoints
- ✅ Schémas de requête/réponse
- ✅ Interface "Try it out" pour tester directement
- ✅ Exemples de réponses

---

## Utiliser l'IA pour générer l'API

### Prompt efficace

```
J'ai ce fichier swagger.json qui décrit mon API :
[COLLER docs/swagger.json]

J'ai aussi cette logique métier dans src/core.py :
[COLLER core.py]

Génère le code Flask pour src/api.py qui :
1. Implémente tous les endpoints définis dans swagger.json
2. Réutilise les fonctions de core.py
3. Respecte exactement les formats de réponse de la spec
4. Gère tous les cas d'erreur (400, 404, 422, 500)
5. Intègre Swagger UI sur /docs

Le code doit passer tous les tests d'acceptance dans docs/api-acceptance-tests.md
```

### Vérifier la conformité

```
J'ai généré cette API :
[COLLER api.py]

Compare-la avec swagger.json et dis-moi :
1. Est-ce que tous les endpoints sont implémentés ?
2. Est-ce que les réponses respectent les schémas ?
3. Est-ce que les codes d'erreur sont corrects ?
4. Manque-t-il des validations ?
```

---

## Tests automatisés pour l'API

### test_api.py

```python
# tests/test_api.py
import pytest
import json
from src.api import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health(client):
    """Test healthcheck endpoint"""
    response = client.get('/api/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'

def test_analyze_valid_csv(client):
    """Test analyse d'un CSV valide"""
    with open('data/sales.csv', 'rb') as f:
        response = client.post('/api/analyze',
                               data={'file': (f, 'sales.csv')},
                               content_type='multipart/form-data')

    assert response.status_code == 200
    data = response.get_json()
    assert data['total'] == 3756.94
    assert len(data['top_products']) == 3
    assert 'Paris' in data['ca_by_city']

def test_analyze_no_file(client):
    """Test sans fichier"""
    response = client.post('/api/analyze')
    assert response.status_code == 400
    data = response.get_json()
    assert 'error' in data

def test_stats_after_analysis(client):
    """Test stats après une analyse"""
    # D'abord analyser
    with open('data/sales.csv', 'rb') as f:
        client.post('/api/analyze',
                   data={'file': (f, 'sales.csv')},
                   content_type='multipart/form-data')

    # Puis récupérer les stats
    response = client.get('/api/stats')
    assert response.status_code == 200
    data = response.get_json()
    assert data['total'] == 3756.94
```

**Lancer** : `pytest tests/test_api.py -v`

---

## Checklist finale pour TP4

- [ ] `docs/swagger.json` créé et complet
- [ ] `src/api.py` implémente tous les endpoints
- [ ] Swagger UI accessible sur http://localhost:5000/docs
- [ ] Tous les tests curl passent (7 tests)
- [ ] Tests pytest passent
- [ ] Les 3 modes fonctionnent : CLI + Web + API
- [ ] Réponses conformes à la spec OpenAPI
- [ ] Gestion d'erreurs complète (400, 404, 422, 500)

---

## Pour aller plus loin

### CORS (pour frontend externe)

```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Permet les requêtes cross-origin
```

### Rate limiting

```python
from flask_limiter import Limiter

limiter = Limiter(app, default_limits=["100 per hour"])

@app.route('/api/analyze')
@limiter.limit("10 per minute")
def analyze():
    # ...
```

### Authentification (JWT)

```python
from flask_jwt_extended import JWTManager, jwt_required

app.config['JWT_SECRET_KEY'] = 'super-secret'
jwt = JWTManager(app)

@app.route('/api/analyze')
@jwt_required()
def analyze():
    # Requiert un token JWT valide
```

---

## Ressources

- [OpenAPI Specification](https://swagger.io/specification/)
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
- [Flask-RESTX](https://flask-restx.readthedocs.io/) (alternative avec génération auto de Swagger)
- [API Design Best Practices](https://github.com/microsoft/api-guidelines)
