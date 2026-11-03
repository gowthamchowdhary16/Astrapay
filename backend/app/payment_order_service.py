import uuid
from decimal import Decimal

from sqlalchemy.orm import Session

from app.models import PaymentOrder, Wallet


def create_payment_order(
    db: Session,
    user_id,
    amount: Decimal,
    payment_method: str,
    recipient_value: str
):
    wallet = (
        db.query(Wallet)
        .filter(Wallet.user_id == user_id)
        .with_for_update()
        .first()
    )

    if wallet is None:
        raise ValueError("Wallet not found")

    if wallet.status != "ACTIVE":
        raise ValueError("Wallet is not active")

    if Decimal(wallet.balance) < amount:
        raise ValueError("Insufficient wallet balance")

    allowed_methods = {
        "UPI",
        "BANK_ACCOUNT",
        "PHONE"
    }

    payment_method = payment_method.upper().strip()

    if payment_method not in allowed_methods:
        raise ValueError(
            "Unsupported payment method"
        )

    payment = PaymentOrder(
        user_id=user_id,
        amount=amount,
        payment_method=payment_method,
        recipient_value=recipient_value.strip(),
        status="CREATED",
        partner_reference=None
    )

    db.add(payment)
    db.flush()

    return payment