import unittest

from app.cart import CartItem, calculate_subtotal, calculate_total


class CartTests(unittest.TestCase):
    def test_calculate_subtotal(self):
        items = [
            CartItem("A-100", 2, 12.50),
            CartItem("B-200", 1, 5.00),
        ]

        self.assertEqual(calculate_subtotal(items), 30.00)

    def test_calculate_total_with_tax(self):
        items = [CartItem("A-100", 2, 50.00)]

        self.assertEqual(calculate_total(items, tax_rate=0.2), 120.00)

    def test_rejects_negative_quantity(self):
        items = [CartItem("A-100", -1, 50.00)]

        with self.assertRaises(ValueError):
            calculate_subtotal(items)

    def test_rejects_negative_tax_rate(self):
        items = [CartItem("A-100", 1, 50.00)]

        with self.assertRaises(ValueError):
            calculate_total(items, tax_rate=-0.1)


if __name__ == "__main__":
    unittest.main()

