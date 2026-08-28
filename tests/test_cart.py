import unittest

from app.cart import CartItem, calculate_subtotal, calculate_total


class CalculateSubtotalTests(unittest.TestCase):
    def test_empty_cart_is_zero(self):
        self.assertEqual(calculate_subtotal([]), 0.0)

    def test_sums_quantity_times_price(self):
        items = [
            CartItem(sku="A", quantity=2, unit_price=10.00),
            CartItem(sku="B", quantity=1, unit_price=5.50),
        ]
        self.assertEqual(calculate_subtotal(items), 25.50)

    def test_rounds_to_two_decimal_places(self):
        items = [CartItem(sku="A", quantity=3, unit_price=0.335)]
        self.assertEqual(calculate_subtotal(items), 1.01)

    def test_rejects_negative_quantity(self):
        items = [CartItem(sku="A", quantity=-1, unit_price=10.00)]
        with self.assertRaises(ValueError):
            calculate_subtotal(items)

    def test_rejects_negative_unit_price(self):
        items = [CartItem(sku="A", quantity=1, unit_price=-10.00)]
        with self.assertRaises(ValueError):
            calculate_subtotal(items)


class CalculateTotalTests(unittest.TestCase):
    def test_defaults_to_no_tax(self):
        items = [CartItem(sku="A", quantity=2, unit_price=10.00)]
        self.assertEqual(calculate_total(items), 20.00)

    def test_applies_tax_rate(self):
        items = [CartItem(sku="A", quantity=2, unit_price=10.00)]
        self.assertEqual(calculate_total(items, tax_rate=0.10), 22.00)

    def test_rejects_negative_tax_rate(self):
        items = [CartItem(sku="A", quantity=1, unit_price=10.00)]
        with self.assertRaises(ValueError):
            calculate_total(items, tax_rate=-0.10)

    def test_validation_applies_through_total(self):
        items = [CartItem(sku="A", quantity=-1, unit_price=10.00)]
        with self.assertRaises(ValueError):
            calculate_total(items)


if __name__ == "__main__":
    unittest.main()
