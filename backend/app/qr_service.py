from urllib.parse import quote

from app.payment_service import validate_upi_id


def create_upi_qr_payload(
    upi_id: str,
    amount: float | None = None,
    name: str | None = None
):
    upi_id = upi_id.strip().lower()

    if not validate_upi_id(upi_id):
        raise ValueError("Invalid UPI ID")

    params = [
        f"pa={quote(upi_id)}"
    ]

    if name:
        params.append(f"pn={quote(name.strip())}")

    if amount is not None:
        params.append(f"am={amount:.2f}")

    params.append("cu=INR")

    return "upi://pay?" + "&".join(params)