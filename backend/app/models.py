import uuid

from sqlalchemy import (
    Column,
    String,
    Boolean,
    Date,
    DateTime,
    Numeric,
    ForeignKey,
)

from sqlalchemy.dialects.postgresql import UUID

from sqlalchemy.sql import func

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    phone = Column(
        String(15),
        unique=True,
        nullable=False
    )

    full_name = Column(
        String(100),
        nullable=False
    )

    date_of_birth = Column(
        Date,
        nullable=False
    )

    age_group = Column(
        String(20),
        nullable=False
    )

    pan_verified = Column(
        Boolean,
        default=False,
        nullable=False
    )

    kyc_status = Column(
        String(20),
        default="PENDING",
        nullable=False
    )

    otp_code = Column(
        String(6),
        nullable=True
    )

    otp_expires_at = Column(
        DateTime(timezone=True),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class Wallet(Base):
    __tablename__ = "wallets"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        unique=True,
        nullable=False
    )

    balance = Column(
        Numeric(12, 2),
        default=0,
        nullable=False
    )

    currency = Column(
        String(3),
        default="INR",
        nullable=False
    )

    status = Column(
        String(20),
        default="ACTIVE",
        nullable=False
    )

    daily_limit = Column(
        Numeric(12, 2),
        nullable=True
    )

    monthly_limit = Column(
        Numeric(12, 2),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class WalletTransaction(Base):
    __tablename__ = "wallet_transactions"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    wallet_id = Column(
        UUID(as_uuid=True),
        ForeignKey("wallets.id"),
        nullable=False
    )

    transaction_type = Column(
        String(30),
        nullable=False
    )

    amount = Column(
        Numeric(12, 2),
        nullable=False
    )

    status = Column(
        String(20),
        default="PENDING",
        nullable=False
    )

    recipient_type = Column(
        String(30),
        nullable=True
    )

    recipient_value = Column(
        String(255),
        nullable=True
    )

    reference_id = Column(
        String(100),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class ParentNotification(Base):
    __tablename__ = "parent_notifications"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    transaction_id = Column(
        UUID(as_uuid=True),
        ForeignKey("wallet_transactions.id"),
        nullable=False
    )

    amount = Column(
        Numeric(12, 2),
        nullable=False
    )

    message = Column(
        String(500),
        nullable=False
    )

    is_read = Column(
        Boolean,
        default=False,
        nullable=False
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )
class UPIAccount(Base):
    __tablename__ = "upi_accounts"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    upi_id = Column(
        String(100),
        unique=True,
        nullable=False
    )

    is_primary = Column(
        Boolean,
        default=False,
        nullable=False
    )

    status = Column(
        String(20),
        default="ACTIVE",
        nullable=False
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )


class BankAccount(Base):
    __tablename__ = "bank_accounts"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    account_holder_name = Column(
        String(100),
        nullable=False
    )

    account_number = Column(
        String(30),
        nullable=False
    )

    ifsc_code = Column(
        String(20),
        nullable=False
    )

    is_primary = Column(
        Boolean,
        default=False,
        nullable=False
    )

    status = Column(
        String(20),
        default="ACTIVE",
        nullable=False
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )
class PaymentOrder(Base):
    __tablename__ = "payment_orders"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    amount = Column(
        Numeric(12, 2),
        nullable=False
    )

    payment_method = Column(
        String(30),
        nullable=False
    )

    recipient_value = Column(
        String(255),
        nullable=False
    )

    status = Column(
        String(30),
        default="CREATED",
        nullable=False
    )

    partner_reference = Column(
        String(100),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )
class PaymentEvent(Base):
    __tablename__ = "payment_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    payment_id = Column(
        UUID(as_uuid=True),
        ForeignKey("payment_orders.id"),
        nullable=False
    )

    event_id = Column(
        String(100),
        unique=True,
        nullable=False
    )

    event_type = Column(
        String(50),
        nullable=False
    )

    status = Column(
        String(30),
        nullable=False
    )

    partner_reference = Column(
        String(100),
        nullable=True
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now()
    )