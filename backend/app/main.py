from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from decimal import Decimal
from app.database import engine, Base, get_db
from app.models import ParentNotification
from app import models
from app.qr_service import create_upi_qr_payload
from app.payment_webhook_service import process_payment_webhook
from app.payment_order_service import create_payment_order
from app.payment_service import (
    add_upi_account,
    add_bank_account
)
from app.schemas import (
    UserRegister,
    UserRegisterResponse,
    SendOTPRequest,
    OTPResponse,
    VerifyOTPRequest,
    LoginResponse,
    WalletBalanceResponse,
    AddMoneyRequest,
    AddMoneyResponse,
    TransactionResponse,
    SendMoneyRequest,
    SendMoneyResponse,
    ParentNotificationResponse,
    AddUPIRequest,
    UPIResponse,
    AddBankAccountRequest,
    BankAccountResponse,
    CreatePaymentRequest,
    PaymentOrderResponse,
    PaymentWebhookRequest,
    CreateQRRequest,
    QRResponse
)
from app.wallet_service import (
    get_balance,
    add_money,
    get_transaction_history,
    send_money
)
from app.dependencies import get_current_user
from app.wallet_service import get_balance, add_money
from decimal import Decimal
from app.schemas import (
    UserRegister,
    UserRegisterResponse,
    SendOTPRequest,
    OTPResponse,
    VerifyOTPRequest,
    LoginResponse
)

from app.user_service import create_user
from app.auth_service import create_otp, verify_otp


# Create database tables
Base.metadata.create_all(bind=engine)


# Create FastAPI application
app = FastAPI(
    title="AstraPay API",
    description="AstraPay Digital Wallet Backend",
    version="1.0.0"
)


# ---------------------------------------------------------
# ROOT
# ---------------------------------------------------------

@app.get("/")
def root():
    return {
        "app": "AstraPay",
        "status": "online",
        "message": "AstraPay backend is running"
    }


# ---------------------------------------------------------
# HEALTH CHECK
# ---------------------------------------------------------

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "database": "connected"
    }


# ---------------------------------------------------------
# USER REGISTRATION
# ---------------------------------------------------------

@app.post(
    "/users/register",
    response_model=UserRegisterResponse
)
def register_user(
    user_data: UserRegister,
    db: Session = Depends(get_db)
):
    try:
        user, wallet = create_user(
            db=db,
            phone=user_data.phone,
            full_name=user_data.full_name,
            date_of_birth=user_data.date_of_birth
        )

        return {
            "user_id": str(user.id),
            "full_name": user.full_name,
            "age_group": user.age_group,
            "kyc_status": user.kyc_status,
            "wallet_id": str(wallet.id),
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

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )


# ---------------------------------------------------------
# SEND OTP
# ---------------------------------------------------------

@app.post(
    "/auth/send-otp",
    response_model=OTPResponse
)
def send_otp(
    request: SendOTPRequest,
    db: Session = Depends(get_db)
):
    user = (
        db.query(models.User)
        .filter(models.User.phone == request.phone)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # Generate and save OTP
    otp = create_otp(
        db=db,
        user=user
    )

    # Development-only OTP display
    print(
        f"AstraPay OTP for {user.phone}: {otp}"
    )

    return {
        "message": "OTP generated successfully",
        "development_otp": otp
    }


# ---------------------------------------------------------
# VERIFY OTP / LOGIN
# ---------------------------------------------------------

@app.post(
    "/auth/verify-otp",
    response_model=LoginResponse
)
def verify_user_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
):
    user = (
        db.query(models.User)
        .filter(models.User.phone == request.phone)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    token = verify_otp(
        db=db,
        user=user,
        otp=request.otp
    )

    if token is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired OTP"
        )

    return {
        "message": "Login successful",
        "access_token": token,
        "token_type": "bearer"
    }
@app.get(
    "/wallet/balance",
    response_model=WalletBalanceResponse
)
def wallet_balance(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        return get_balance(
            db=db,
            user_id=current_user.id
        )

    except ValueError as error:
        raise HTTPException(
            status_code=404,
            detail=str(error)
        )
@app.post(
    "/wallet/add-money",
    response_model=AddMoneyResponse
)
def wallet_add_money(
    request: AddMoneyRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        wallet, transaction = add_money(
            db=db,
            user_id=current_user.id,
            amount=Decimal(str(request.amount))
        )

        return {
            "message": "Money added successfully",
            "transaction_id": str(transaction.id),
            "wallet_id": str(wallet.id),
            "balance": float(wallet.balance),
            "amount_added": float(request.amount)
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )
@app.get(
    "/wallet/transactions",
    response_model=list[TransactionResponse]
)
def wallet_transactions(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    transactions = get_transaction_history(
        db=db,
        user_id=current_user.id
    )

    return [
        {
            "transaction_id": str(transaction.id),
            "transaction_type": transaction.transaction_type,
            "amount": float(transaction.amount),
            "status": transaction.status,
            "recipient_type": transaction.recipient_type,
            "recipient_value": transaction.recipient_value,
            "reference_id": transaction.reference_id,
            "created_at": transaction.created_at.isoformat()
            if transaction.created_at
            else ""
        }
        for transaction in transactions
    ]
@app.post(
    "/wallet/send-money",
    response_model=SendMoneyResponse
)
def wallet_send_money(
    request: SendMoneyRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        wallet, transaction = send_money(
            db=db,
            sender=current_user,
            recipient_phone=request.recipient_phone,
            amount=Decimal(str(request.amount))
        )

        return {
            "message": "Money sent successfully",
            "transaction_id": str(transaction.id),
            "amount": float(transaction.amount),
            "recipient_phone": request.recipient_phone,
            "remaining_balance": float(wallet.balance)
        }

    except ValueError as error:
         db.rollback()
         raise HTTPException(
            status_code=400,
            detail=str(error)
        )

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Transaction failed"
        )
@app.get(
    "/notifications",
    response_model=list[ParentNotificationResponse]
)
def get_notifications(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    notifications = (
        db.query(ParentNotification)
        .filter(
            ParentNotification.user_id == current_user.id
        )
        .order_by(
            ParentNotification.created_at.desc()
        )
        .all()
    )

    return [
        {
            "notification_id": str(notification.id),
            "transaction_id": str(notification.transaction_id),
            "amount": float(notification.amount),
            "message": notification.message,
            "is_read": notification.is_read,
            "created_at": (
                notification.created_at.isoformat()
                if notification.created_at
                else ""
            )
        }
        for notification in notifications
    ]


@app.post(
    "/payment/upi",
    response_model=UPIResponse
)
def add_user_upi(
    request: AddUPIRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        account = add_upi_account(
            db=db,
            user_id=current_user.id,
            upi_id=request.upi_id
        )

        return {
            "id": str(account.id),
            "upi_id": account.upi_id,
            "is_primary": account.is_primary,
            "status": account.status
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )
@app.post(
    "/payment/bank-account",
    response_model=BankAccountResponse
)
def add_user_bank_account(
    request: AddBankAccountRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        account = add_bank_account(
            db=db,
            user_id=current_user.id,
            account_holder_name=request.account_holder_name,
            account_number=request.account_number,
            ifsc_code=request.ifsc_code
        )

        return {
            "id": str(account.id),
            "account_holder_name": account.account_holder_name,
            "account_number": account.account_number,
            "ifsc_code": account.ifsc_code,
            "is_primary": account.is_primary,
            "status": account.status
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )
@app.post(
    "/payments/create",
    response_model=PaymentOrderResponse
)
def create_payment(
    request: CreatePaymentRequest,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        payment = create_payment_order(
            db=db,
            user_id=current_user.id,
            amount=Decimal(str(request.amount)),
            payment_method=request.payment_method,
            recipient_value=request.recipient_value
        )

        db.commit()
        db.refresh(payment)

        return {
            "payment_id": str(payment.id),
            "amount": float(payment.amount),
            "payment_method": payment.payment_method,
            "recipient_value": payment.recipient_value,
            "status": payment.status,
            "partner_reference": payment.partner_reference
        }

    except ValueError as error:
        db.rollback()

        raise HTTPException(
            status_code=400,
            detail=str(error)
        )

    except Exception:
        db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Unable to create payment"
        )
@app.get("/payments/{payment_id}", response_model=PaymentOrderResponse)
def get_payment_status(
    payment_id: str,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    payment = (
        db.query(models.PaymentOrder)
        .filter(
            models.PaymentOrder.id == payment_id,
            models.PaymentOrder.user_id == current_user.id
        )
        .first()
    )

    if payment is None:
        raise HTTPException(status_code=404, detail="Payment not found")

    return {
        "payment_id": str(payment.id),
        "amount": float(payment.amount),
        "payment_method": payment.payment_method,
        "recipient_value": payment.recipient_value,
        "status": payment.status,
        "partner_reference": payment.partner_reference
    }
@app.post("/payments/webhook")
def payment_webhook(
    request: PaymentWebhookRequest,
    db: Session = Depends(get_db)
):
    try:
        payment = process_payment_webhook(
            db=db,
            event_id=request.event_id,
            payment_id=request.payment_id,
            status=request.status,
            partner_reference=request.partner_reference
        )

        return {
            "message": "Webhook processed successfully",
            "payment_id": str(payment.id),
            "status": payment.status,
            "partner_reference": payment.partner_reference
        }

    except ValueError as error:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )

    except Exception:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail="Webhook processing failed"
        )
@app.post("/payment/qr", response_model=QRResponse)
def create_qr(
    request: CreateQRRequest,
    current_user=Depends(get_current_user)
):
    try:
        payload = create_upi_qr_payload(
            upi_id=request.upi_id,
            amount=request.amount,
            name=request.name
        )

        return {
            "upi_id": request.upi_id.strip().lower(),
            "amount": request.amount,
            "name": request.name,
            "qr_payload": payload
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error)
        )