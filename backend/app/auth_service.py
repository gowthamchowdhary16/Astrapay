import random
from datetime import datetime, timedelta, timezone

from jose import jwt
from sqlalchemy.orm import Session

from app.models import User


SECRET_KEY = "CHANGE_THIS_IN_PRODUCTION"
ALGORITHM = "HS256"
OTP_EXPIRY_MINUTES = 5


def generate_otp() -> str:
    return str(random.randint(100000, 999999))


def create_otp(db: Session, user: User) -> str:
    otp = generate_otp()

    user.otp_code = otp
    user.otp_expires_at = (
        datetime.now(timezone.utc)
        + timedelta(minutes=OTP_EXPIRY_MINUTES)
    )

    db.commit()
    db.refresh(user)

    return otp


def verify_otp(db: Session, user: User, otp: str):
    if user.otp_code is None:
        return None

    if user.otp_expires_at is None:
        return None

    now = datetime.now(timezone.utc)

    if now > user.otp_expires_at:
        return None

    if user.otp_code != otp:
        return None

    user.otp_code = None
    user.otp_expires_at = None

    token = jwt.encode(
        {
            "sub": str(user.id),
            "exp": now + timedelta(hours=24)
        },
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    db.commit()

    return token