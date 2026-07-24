from dataclasses import dataclass


@dataclass(frozen=True)
class CartItem:
    sku: str
    quantity: int
    unit_price: float


def calculate_subtotal(items: list[CartItem]) -> float:
    subtotal = 0.0
    for item in items:
        if item.quantity < 0:
            raise ValueError("quantity cannot be negative")
        if item.unit_price < 0:
            raise ValueError("unit price cannot be negative")
        subtotal += item.quantity * item.unit_price
    return round(subtotal, 2)


def calculate_total(items: list[CartItem], tax_rate: float = 0.0) -> float:
    if tax_rate < 0:
        raise ValueError("tax rate cannot be negative")
    subtotal = calculate_subtotal(items)
    return round(subtotal * (1 + tax_rate), 2)

