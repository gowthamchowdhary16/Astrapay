from fastapi import APIRouter
from pydantic import BaseModel
import random

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

otp_storage = {}


class SendOTPRequest(BaseModel):
    phone: str


class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str


@router.post("/send-otp")
def send_otp(data: SendOTPRequest):

    otp = str(random.randint(100000, 999999))

    otp_storage[data.phone] = otp

    print(f"OTP for {data.phone}: {otp}")

    return {
        "success": True,
        "message": "OTP sent successfully",
        "phone": data.phone,
        "otp": otp
    }


@router.post("/verify-otp")
def verify_otp(data: VerifyOTPRequest):

    saved_otp = otp_storage.get(data.phone)

    if not saved_otp:
        return {
            "success": False,
            "message": "OTP expired or not found"
        }

    if saved_otp != data.otp:
        return {
            "success": False,
            "message": "Invalid OTP"
        }

    del otp_storage[data.phone]

    return {
        "success": True,
        "message": "OTP verified successfully",
        "phone": data.phone
    }