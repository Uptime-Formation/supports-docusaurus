# Stack : Python + FastAPI + SQLAlchemy

## Configuration pour `.cursorrules` ou `CLAUDE.md`

### Langage et version
- Python 3.11
- Type hints obligatoires (strict mode mypy)
- Pydantic v2 pour validation

### Framework principal
- FastAPI pour API REST
- Async/await obligatoire (pas de code bloquant)
- Tous les endpoints doivent avoir une dépendance Depends()

### Base de données
- SQLAlchemy ORM (pas de raw SQL)
- Alembic pour migrations
- Connexion async avec asyncpg

---

## Exemple de pattern : Endpoint avec dépendances

```python
# db: AsyncSession est TOUJOURS injecté par Depends()
# user: User est TOUJOURS validé et actif
# request_data est TOUJOURS validé via Pydantic

@router.post("/users", response_model=UserResponse)
async def create_user(
    request: CreateUserRequest,  # Pydantic
    db: AsyncSession = Depends(get_db),  # Injection DB
    current_user: User = Depends(get_current_user),  # Auth
) -> UserResponse:
    """Créer un nouvel utilisateur.
    
    Seuls les admins peuvent créer des users.
    """
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin required")
    
    user = User(**request.dict())
    db.add(user)
    await db.commit()
    return user
```

---

## Test : Même approche avec pytest-asyncio

```python
# tests/test_users.py

@pytest.mark.asyncio
async def test_create_user_success(db_session):
    """Tester création d'user valide."""
    response = await client.post(
        "/users",
        json={"email": "test@example.com", "name": "Test"},
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 201
    assert response.json()["email"] == "test@example.com"
```

---

## Checklist pour tout code Python

- [ ] Type hints complets
- [ ] Docstring au format Google
- [ ] Async/await si I/O (DB, HTTP)
- [ ] Gestion erreurs : HTTPException, ValidationError
- [ ] Logs avec contexte (pas de données sensibles)
- [ ] Tests : 1 success + 1 error case minimum
