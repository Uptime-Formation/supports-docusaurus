# Erreurs, Logging et Configuration

## Hiérarchie d'exceptions

```python
# domain/exceptions.py

class DomainError(Exception):
    """Exception métier de base."""
    pass

class ValidationError(DomainError):
    """Données invalides."""
    pass

class NotFoundError(DomainError):
    """Resource pas trouvée."""
    pass

class ConflictError(DomainError):
    """Resource existe déjà."""
    pass

class PaymentError(DomainError):
    """Erreur paiement."""
    pass
```

---

## Mapper les erreurs métier → HTTP

```python
# application/error_handlers.py

exception_status_map = {
    ValidationError: 400,
    NotFoundError: 404,
    ConflictError: 409,
    PaymentError: 402,
    DomainError: 422,  # Unprocessable Entity
}

@app.exception_handler(DomainError)
async def handle_domain_error(request, exc: DomainError):
    status = exception_status_map.get(type(exc), 500)
    return JSONResponse(
        status_code=status,
        content={"error": str(exc), "type": type(exc).__name__}
    )
```

---

## Logging

```python
# infrastructure/logging.py

import logging

logger = logging.getLogger(__name__)

# Lors d'une création user
logger.info(f"User created", extra={"user_id": user.id, "email": user.email})

# Lors d'une erreur
logger.error(f"Payment failed", extra={"customer_id": cust_id, "amount": amount}, exc_info=True)

# JAMAIS : logger des mots de passe, tokens, données sensibles
logger.debug(f"User password: {password}")  # ❌ MAUVAIS

# BON :
logger.debug(f"User {user.id} authenticated")  # ✅ BON
```

---

## Configuration avec Pydantic Settings

```python
# config/settings.py

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://user:pass@localhost/mydb"
    
    # API
    API_KEY_STRIPE: str  # Obligatoire, depuis env
    API_KEY_SENDGRID: str
    
    # Comportement
    LOG_LEVEL: str = "INFO"
    CORS_ORIGINS: list = ["http://localhost:3000"]
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()

# Utiliser dans l'app
@app.on_event("startup")
async def startup():
    app.state.settings = settings
```

### Variables d'env obligatoires

```bash
# .env.example (commiter ce fichier!)
DATABASE_URL=postgresql://user:pass@localhost/mydb
API_KEY_STRIPE=sk_test_xxxxx
API_KEY_SENDGRID=SG.xxxxx
LOG_LEVEL=INFO
```

### Mauvais vs Bon

```python
# ❌ MAUVAIS : En dur dans le code
stripe.api_key = "sk_live_xxxxx"

# ✅ BON : Depuis settings
stripe.api_key = settings.API_KEY_STRIPE
```

---

## Règles pour l'IA

**Erreurs et Logging :**
- [ ] Lancer DomainError ou sous-classe, jamais ValueError/RuntimeError
- [ ] Capturer exceptions, log, relancer sous forme métier
- [ ] Jamais logguer données sensibles (password, token, card number)
- [ ] Log = contexte utile : IDs, statuts, pas détails techniques

**Configuration :**
- [ ] Lire config depuis Settings
- [ ] Jamais de secrets en dur dans le code
- [ ] `.env` = non commité, `.env.example` = commité
- [ ] Variables obligatoires = pas de valeur par défaut
