# Services tiers : Pattern Adapter

## Définir l'interface (port)

```python
# domain/ports/payment_service.py
from abc import ABC, abstractmethod

class IPaymentService(ABC):
    @abstractmethod
    async def charge(self, amount: float, currency: str, customer_id: str) -> Payment:
        """Charger un client. Retourne Payment ou lève PaymentError."""
        pass
```

---

## Implémenter avec Stripe

```python
# infrastructure/adapters/stripe_payment_service.py
import stripe

class StripePaymentService(IPaymentService):
    def __init__(self, api_key: str):
        stripe.api_key = api_key
    
    async def charge(self, amount: float, currency: str, customer_id: str) -> Payment:
        try:
            intent = stripe.PaymentIntent.create(
                amount=int(amount * 100),  # Stripe utilise cents
                currency=currency,
                customer=customer_id
            )
            return Payment(
                id=intent.id,
                amount=amount,
                status="pending"
            )
        except stripe.error.CardError as e:
            raise PaymentError(f"Card declined: {e.user_message}")
```

---

## Utiliser dans un use case

```python
# application/handlers/charge_customer_handler.py
@router.post("/charges")
async def charge_customer(
    request: ChargeRequest,
    payment_service: IPaymentService = Depends(get_payment_service)
):
    try:
        payment = await payment_service.charge(
            request.amount,
            request.currency,
            request.customer_id
        )
        return {"payment_id": payment.id, "status": payment.status}
    except PaymentError as e:
        raise HTTPException(status_code=402, detail=str(e))
```

---

## Testing : mocker le service

```python
# tests/test_charges.py

@pytest.fixture
def mock_payment_service():
    class MockPaymentService(IPaymentService):
        async def charge(self, amount, currency, customer_id):
            return Payment(id="test_123", amount=amount, status="success")
    
    return MockPaymentService()

@pytest.mark.asyncio
async def test_charge_success(mock_payment_service):
    handler = ChargeCustomerHandler(mock_payment_service)
    result = await handler.charge(100.0, "USD", "cus_123")
    assert result.status == "success"
```

---

## Règles pour l'IA

- [ ] Toujours passer par l'interface (port), jamais direct
- [ ] Adapter = classe qui implémente le port
- [ ] Tests = mocker le port avec un Mock ou Fake
- [ ] Configurations (clés API) = variables d'env, jamais en dur
- [ ] Logging des appels externes (avec IDs de transaction)
