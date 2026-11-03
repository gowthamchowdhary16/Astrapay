from datetime import date

from pydantic import BaseModel, Field


# ==========================================
# USER REGISTRATION
# ==========================================

class UserRegister(BaseModel):
    phone: str = Field(
        min_length=10,
        max_length=15
    )

    full_name: str = Field(
        min_length=2,
        max_length=100
    )

    date_of_birth: date


class UserRegisterResponse(BaseModel):
    user_id: str
    full_name: str
    age_group: str
    kyc_status: str
    wallet_id: str
    daily_limit: float | None
    monthly_limit: float | None


# ==========================================
# SEND OTP
# ==========================================

class SendOTPRequest(BaseModel):
    phone: str = Field(
        min_length=10,
        max_length=15
    )


class OTPResponse(BaseModel):
    message: str
    development_otp: str


# ==========================================
# VERIFY OTP
# ==========================================

class VerifyOTPRequest(BaseModel):
    phone: str = Field(
        min_length=10,
        max_length=15
    )

    otp: str = Field(
        min_length=6,
        max_length=6
    )


class LoginResponse(BaseModel):
    message: str
    access_token: str
    token_type: str
class WalletBalanceResponse(BaseModel):
    wallet_id: str
    balance: float
    currency: str
    status: str
    daily_limit: float | None
    monthly_limit: float | None


class AddMoneyRequest(BaseModel):
    amount: float = Field(gt=0)


class AddMoneyResponse(BaseModel):
    message: str
    transaction_id: str
    wallet_id: str
    balance: float
    amount_added: float
class TransactionResponse(BaseModel):
    transaction_id: str
    transaction_type: str
    amount: float
    status: str
    recipient_type: str | None
    recipient_value: str | None
    reference_id: str | None
    created_at: str
class SendMoneyRequest(BaseModel):
    recipient_phone: str = Field(min_length=10, max_length=15)
    amount: float = Field(gt=0)


class SendMoneyResponse(BaseModel):
    message: str
    transaction_id: str
    amount: float
    recipient_phone: str
    remaining_balance: float
class ParentNotificationResponse(BaseModel):
    notification_id: str
    transaction_id: str
    amount: float
    message: str
    is_read: bool
    created_at: str
class AddUPIRequest(BaseModel):
    upi_id: str = Field(min_length=3, max_length=100)


class UPIResponse(BaseModel):
    id: str
    upi_id: str
    is_primary: bool
    status: str


class AddBankAccountRequest(BaseModel):
    account_holder_name: str = Field(min_length=2, max_length=100)
    account_number: str = Field(min_length=6, max_length=30)
    ifsc_code: str = Field(min_length=4, max_length=20)


class BankAccountResponse(BaseModel):
    id: str
    account_holder_name: str
    account_number: str
    ifsc_code: str
    is_primary: bool
    status: str
class CreatePaymentRequest(BaseModel):
    amount: float = Field(gt=0)
    payment_method: str = Field(
        min_length=3,
        max_length=30
    )
    recipient_value: str = Field(
        min_length=3,
        max_length=255
    )


class PaymentOrderResponse(BaseModel):
    payment_id: str
    amount: float
    payment_method: str
    recipient_value: str
    status: str
    partner_reference: str | None
class PaymentWebhookRequest(BaseModel):
    payment_id: str
    status: str = Field(min_length=3, max_length=30)
    partner_reference: str | None = None
class PaymentWebhookRequest(BaseModel):
    event_id: str = Field(min_length=3, max_length=100)
    payment_id: str
    status: str = Field(min_length=3, max_length=30)
    partner_reference: str | None = None
class CreateQRRequest(BaseModel):
    upi_id: str = Field(min_length=3, max_length=100)
    amount: float | None = Field(default=None, gt=0)
    name: str | None = Field(default=None, max_length=100)


class QRResponse(BaseModel):
    upi_id: str
    amount: float | None
    name: str | None
    qr_payload: str