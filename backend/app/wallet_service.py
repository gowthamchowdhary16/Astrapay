from decimal import Decimal
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models import User, Wallet, WalletTransaction


def get_user_wallet(db: Session, user_id):
    wallet = (
        db.query(Wallet)
        .filter(Wallet.user_id == user_id)
        .first()
    )

    if wallet is None:
        raise ValueError("Wallet not found")

    return wallet


def get_balance(db: Session, user_id):
    wallet = get_user_wallet(db, user_id)

    return {
        "wallet_id": str(wallet.id),
        "balance": float(wallet.balance),
        "currency": wallet.currency,
        "status": wallet.status,
        "daily_limit": (
            float(wallet.daily_limit)
            if wallet.daily_limit is not None
            else None
        ),
        "monthly_limit": (
            float(wallet.monthly_limit)
            if wallet.monthly_limit is not None
            else None
        )
    }


def add_money(
    db: Session,
    user_id,
    amount: Decimal
):
    if amount <= 0:
        raise ValueError("Amount must be greater than zero")

    wallet = get_user_wallet(db, user_id)

    wallet.balance = Decimal(wallet.balance) + amount

    transaction = WalletTransaction(
        wallet_id=wallet.id,
        transaction_type="ADD_MONEY",
        amount=amount,
        status="SUCCESS",
        recipient_type=None,
        recipient_value=None,
        reference_id=f"ASTRA-{int(datetime.now(timezone.utc).timestamp())}"
    )

    db.add(transaction)
    db.commit()
    db.refresh(wallet)
    db.refresh(transaction)

    return wallet, transaction
def get_transaction_history(db: Session, user_id):
    wallet = get_user_wallet(db, user_id)

    transactions = (
        db.query(WalletTransaction)
        .filter(WalletTransaction.wallet_id == wallet.id)
        .order_by(WalletTransaction.created_at.desc())
        .all()
    )

    return transactions
def send_money(
    db: Session,
    sender: User,
    recipient_phone: str,
    amount: Decimal
):
    if amount <= 0:
        raise ValueError("Amount must be greater than zero")

    # Prevent sending to yourself
    if sender.phone == recipient_phone:
        raise ValueError("You cannot send money to yourself")

    # Find recipient
    recipient = (
        db.query(User)
        .filter(User.phone == recipient_phone)
        .first()
    )

    if recipient is None:
        raise ValueError("Recipient not found")

    # Get sender wallet
    sender_wallet = (
        db.query(Wallet)
        .filter(Wallet.user_id == sender.id)
        .with_for_update()
        .first()
    )

    # Get recipient wallet
    recipient_wallet = (
        db.query(Wallet)
        .filter(Wallet.user_id == recipient.id)
        .with_for_update()
        .first()
    )

    if sender_wallet is None:
        raise ValueError("Sender wallet not found")

    if recipient_wallet is None:
        raise ValueError("Recipient wallet not found")

    if sender_wallet.status != "ACTIVE":
        raise ValueError("Sender wallet is not active")

    if recipient_wallet.status != "ACTIVE":
        raise ValueError("Recipient wallet is not active")

    # Check balance
    if Decimal(sender_wallet.balance) < amount:
        raise ValueError("Insufficient wallet balance")

    # --------------------------------------------------
    # Minor wallet limits
    # --------------------------------------------------

    if sender.age_group == "MINOR":

        if sender_wallet.daily_limit is not None:
            from sqlalchemy import func

            daily_total = (
                db.query(func.coalesce(func.sum(WalletTransaction.amount), 0))
                .filter(
                    WalletTransaction.wallet_id == sender_wallet.id,
                    WalletTransaction.transaction_type == "SEND_MONEY",
                    WalletTransaction.status == "SUCCESS",
                    func.date(WalletTransaction.created_at)
                    == func.current_date()
                )
                .scalar()
            )

            daily_total = Decimal(str(daily_total))

            if daily_total + amount > Decimal(sender_wallet.daily_limit):
                raise ValueError(
                    "Daily wallet limit exceeded"
                )

        if sender_wallet.monthly_limit is not None:
            from sqlalchemy import extract, func

            now = datetime.now(timezone.utc)

            monthly_total = (
                db.query(func.coalesce(func.sum(WalletTransaction.amount), 0))
                .filter(
                    WalletTransaction.wallet_id == sender_wallet.id,
                    WalletTransaction.transaction_type == "SEND_MONEY",
                    WalletTransaction.status == "SUCCESS",
                    extract(
                        "year",
                        WalletTransaction.created_at
                    ) == now.year,
                    extract(
                        "month",
                        WalletTransaction.created_at
                    ) == now.month
                )
                .scalar()
            )

            monthly_total = Decimal(str(monthly_total))

            if monthly_total + amount > Decimal(sender_wallet.monthly_limit):
                raise ValueError(
                    "Monthly wallet limit exceeded"
                )

    # --------------------------------------------------
    # Transfer
    # --------------------------------------------------

    sender_wallet.balance = (
        Decimal(sender_wallet.balance) - amount
    )

    recipient_wallet.balance = (
        Decimal(recipient_wallet.balance) + amount
    )

    reference_id = (
        f"ASTRA-{int(datetime.now(timezone.utc).timestamp())}"
    )

    sender_transaction = WalletTransaction(
        wallet_id=sender_wallet.id,
        transaction_type="SEND_MONEY",
        amount=amount,
        status="SUCCESS",
        recipient_type="PHONE",
        recipient_value=recipient_phone,
        reference_id=reference_id
    )

    recipient_transaction = WalletTransaction(
        wallet_id=recipient_wallet.id,
        transaction_type="RECEIVE_MONEY",
        amount=amount,
        status="SUCCESS",
        recipient_type="PHONE",
        recipient_value=sender.phone,
        reference_id=reference_id
    )

    db.add(sender_transaction)
    db.add(recipient_transaction)

# Flush transactions first so their UUIDs are generated
    db.flush()

# --------------------------------------------------
# Parent notification
# --------------------------------------------------

    if sender.age_group == "MINOR" and amount > Decimal("1000"):
        from app.models import ParentNotification

        notification = ParentNotification(
            user_id=sender.id,
            transaction_id=sender_transaction.id,
            amount=amount,
            message=(
                f"AstraPay transaction alert: "
                f"₹{amount} was sent from the wallet."
            ),
            is_read=False
        )

        db.add(notification)

    db.commit()

    db.refresh(sender_wallet)
    db.refresh(sender_transaction)

    return sender_wallet, sender_transaction