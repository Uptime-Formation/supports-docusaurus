---
title: Mémo Kubectl Python
draft: true
weight: 3
---

## Récapitulation des principales syntaxes Python

### Demander et afficher des informations

| Syntaxe                | Description                              |
| ---------------------- | ---------------------------------------- |
| `kubectl create deployment <deploy-name> --image=<image>` | crée un déploiement de l'image nginx        |
| `kubectl expose deploy nginx --port 80 --name nginx1 --type LoadBalancer` | expose un déploiment avec un service de type LoadBalancer |

### Fonctions

```python
def ma_fonction(toto, tutu=3):
    une_valeur = toto * 6 + tutu
    return une_valeur
```

