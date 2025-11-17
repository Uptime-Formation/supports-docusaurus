# Architecture : Hexagonal

## Structure des dossiers

```
src/
  /domain           # Logique métier pure, 0 dépendances externes
    /entities       # User, Order, Product (pas de DB)
    /use_cases      # CreateUser, PlaceOrder (interfaces requises)
    /ports          # IUserRepository, IEmailService (contrats)
  
  /application      # Orchestration, DTO
    /handlers       # Cas d'usage concrets
    /dto            # Requête/réponse
  
  /infrastructure   # Implémentations concrètes
    /adapters
      /persistence  # SQLAlchemy, Prisma
      /email        # SendGrid, SMTP
      /payment      # Stripe API
    /config         # Base de données, variables d'env
```

---

## Exemple : Créer un user

### Domaine (logique métier pure)

```python
# domain/use_cases/create_user.py (AUCUNE DÉPENDANCE EXTERNE)
class CreateUserUseCase:
    def __init__(self, user_repository: IUserRepository):
        self.repo = user_repository
    
    def execute(self, email: str, name: str) -> User:
        if not self._is_valid_email(email):
            raise ValueError("Invalid email")
        
        existing = self.repo.find_by_email(email)
        if existing:
            raise ValueError("User already exists")
        
        user = User(email=email, name=name)
        return self.repo.save(user)
    
    @staticmethod
    def _is_valid_email(email: str) -> bool:
        return "@" in email
```

### Infrastructure (implémentation concrète)

```python
# infrastructure/adapters/persistence/user_repository.py (IMPLÉMENTATION)
class SQLAlchemyUserRepository(IUserRepository):
    def __init__(self, session: Session):
        self.session = session
    
    def find_by_email(self, email: str) -> Optional[User]:
        return self.session.query(UserModel).filter(UserModel.email == email).first()
    
    def save(self, user: User) -> User:
        model = UserModel(email=user.email, name=user.name)
        self.session.add(model)
        self.session.commit()
        return user
```

### Application (orchestration)

```python
# application/handlers/create_user_handler.py (ORCHESTRATION)
@router.post("/users")
async def create_user(request: CreateUserRequest, db: Session = Depends()):
    repository = SQLAlchemyUserRepository(db)
    use_case = CreateUserUseCase(repository)
    
    try:
        user = use_case.execute(request.email, request.name)
        return {"id": user.id, "email": user.email}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

---

## Règles pour l'IA

- [ ] Jamais de dépendances externes dans `/domain`
- [ ] `/domain` = Logique métier pure testable
- [ ] `/infrastructure` = Détails techniques (DB, API, etc.)
- [ ] Les ports (`IUserRepository`) sont des interfaces, pas des implémentations
- [ ] Tests : mocker les repositories, tester la logique métier en isolation
