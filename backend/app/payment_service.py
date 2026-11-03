import re

from sqlalchemy.orm import Session

from app.models import UPIAccount, BankAccount


def validate_upi_id(upi_id: str) -> bool:
    pattern = r"^[a-zA-Z0-9._-]{2,}@[a-zA-Z0-9._-]{2,}$"
    return bool(re.match(pattern, upi_id))


def add_upi_account(
    db: Session,
    user_id,
    upi_id: str
):
    upi_id = upi_id.strip().lower()

    if not validate_upi_id(upi_id):
        raise ValueError("Invalid UPI ID format")

    existing = (
        db.query(UPIAccount)
        .filter(UPIAccount.upi_id == upi_id)
        .first()
    )

    if existing:
        raise ValueError("UPI ID already registered")

    existing_count = (
        db.query(UPIAccount)
        .filter(UPIAccount.user_id == user_id)
        .count()
    )

    account = UPIAccount(
        user_id=user_id,
        upi_id=upi_id,
        is_primary=(existing_count == 0),
        status="ACTIVE"
    )

    db.add(account)
    db.commit()
    db.refresh(account)

    return account


def add_bank_account(
    db: Session,
    user_id,
    account_holder_name: str,
    account_number: str,
    ifsc_code: str
):
    account_number = account_number.strip()
    ifsc_code = ifsc_code.strip().upper()

    if not account_number.isdigit():
        raise ValueError("Bank account number must contain digits only")

    if not re.match(
        r"^[A-Z]{4}0[A-Z0-9]{6}$",
        ifsc_code
    ):
        raise ValueError("Invalid IFSC code format")

    existing_count = (
        db.query(BankAccount)
        .filter(BankAccount.user_id == user_id)
        .count()
    )

    account = BankAccount(
        user_id=user_id,
        account_holder_name=account_holder_name.strip(),
        account_number=account_number,
        ifsc_code=ifsc_code,
        is_primary=(existing_count == 0),
        status="ACTIVE"
    )

    db.add(account)
    db.commit()
    db.refresh(account)

    return account