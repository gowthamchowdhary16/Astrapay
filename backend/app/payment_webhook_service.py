from decimal import Decimal

from sqlalchemy.orm import Session

from app.models import (
    PaymentOrder,
    PaymentEvent,
    Wallet,
    WalletTransaction,
    ParentNotification,
    User
)


def process_payment_webhook(
    db: Session,
    event_id: str,
    payment_id: str,
    status: str,
    partner_reference: str | None = None
):
    status = status.upper().strip()

    allowed_statuses = {
        "PROCESSING",
        "SUCCESS",
        "FAILED"
    }

    if status not in allowed_statuses:
        raise ValueError("Invalid payment status")

    # Check whether this webhook was already processed
    existing_event = (
        db.query(PaymentEvent)
        .filter(PaymentEvent.event_id == event_id)
        .first()
    )

    if existing_event:
        payment = (
            db.query(PaymentOrder)
            .filter(PaymentOrder.id == payment_id)
            .first()
        )

        if payment is None:
            raise ValueError("Payment not found")

        return payment

    # Lock payment row
    payment = (
        db.query(PaymentOrder)
        .filter(PaymentOrder.id == payment_id)
        .with_for_update()
        .first()
    )

    if payment is None:
        raise ValueError("Payment not found")

    # Record webhook event
    event = PaymentEvent(
        payment_id=payment.id,
        event_id=event_id,
        event_type=f"PAYMENT_{status}",
        status=status,
        partner_reference=partner_reference
    )

    db.add(event)

    if partner_reference:
        payment.partner_reference = partner_reference

    payment.status = status

    # Processing / failed events don't touch wallet
    if status != "SUCCESS":
        db.commit()
        db.refresh(payment)
        return payment

    wallet = (
        db.query(Wallet)
        .filter(Wallet.user_id == payment.user_id)
        .with_for_update()
        .first()
    )

    if wallet is None:
        raise ValueError("Wallet not found")

    amount = Decimal(payment.amount)

    # Idempotency protection for wallet transaction
    existing_transaction = (
        db.query(WalletTransaction)
        .filter(
            WalletTransaction.reference_id
            == f"PAYMENT-{payment.id}"
        )
        .first()
    )

    if existing_transaction:
        db.commit()
        db.refresh(payment)
        return payment

    if Decimal(wallet.balance) < amount:
        payment.status = "FAILED"

        db.commit()
        db.refresh(payment)

        return payment

    # Deduct wallet exactly once
    wallet.balance = Decimal(wallet.balance) - amount

    transaction = WalletTransaction(
        wallet_id=wallet.id,
        transaction_type="PAYMENT",
        amount=amount,
        status="SUCCESS",
        recipient_type=payment.payment_method,
        recipient_value=payment.recipient_value,
        reference_id=f"PAYMENT-{payment.id}"
    )

    db.add(transaction)
    db.flush()

    # Parent notification for minor payments > ₹1,000
    user = (
        db.query(User)
        .filter(User.id == payment.user_id)
        .first()
    )

    if (
        user
        and user.age_group == "MINOR"
        and amount > Decimal("1000")
    ):
        notification = ParentNotification(
            user_id=user.id,
            transaction_id=transaction.id,
            amount=amount,
            message=(
                f"AstraPay payment of ₹{amount} "
                f"was completed."
            ),
            is_read=False
        )

        db.add(notification)

    db.commit()
    db.refresh(payment)

    return payment