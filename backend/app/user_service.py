from datetime import date

from sqlalchemy.orm import Session

from app.models import User, Wallet


def calculate_age(date_of_birth: date) -> int:
    today = date.today()

    age = today.year - date_of_birth.year

    if (today.month, today.day) < (
        date_of_birth.month,
        date_of_birth.day
    ):
        age -= 1

    return age


def create_user(
    db: Session,
    phone: str,
    full_name: str,
    date_of_birth: date
):
    existing_user = (
        db.query(User)
        .filter(User.phone == phone)
        .first()
    )

    if existing_user:
        raise ValueError("Phone number already registered")

    age = calculate_age(date_of_birth)

    if age < 18:
        age_group = "MINOR"
        daily_limit = 2000
        monthly_limit = 50000
        kyc_status = "PENDING"
    else:
        age_group = "ADULT"
        daily_limit = None
        monthly_limit = None
        kyc_status = "PENDING"

    user = User(
        phone=phone,
        full_name=full_name,
        date_of_birth=date_of_birth,
        age_group=age_group,
        kyc_status=kyc_status,
        pan_verified=False
    )

    db.add(user)
    db.flush()

    wallet = Wallet(
        user_id=user.id,
        balance=0,
        currency="INR",
        status="ACTIVE",
        daily_limit=daily_limit,
        monthly_limit=monthly_limit
    )

    db.add(wallet)
    db.commit()

    db.refresh(user)
    db.refresh(wallet)

    return user, wallet