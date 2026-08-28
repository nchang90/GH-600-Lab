import unittest

from app.api import compute


class ComputeTests(unittest.TestCase):
    def test_empty_payload_is_zero(self):
        self.assertEqual(compute({}), {"total": 0.0})

    def test_sums_items(self):
        payload = {
            "items": [
                {"sku": "A", "quantity": 2, "unit_price": 10.00},
                {"sku": "B", "quantity": 1, "unit_price": 5.50},
            ]
        }
        self.assertEqual(compute(payload), {"total": 25.50})

    def test_applies_tax_rate(self):
        payload = {
            "items": [{"sku": "A", "quantity": 2, "unit_price": 10.00}],
            "tax_rate": 0.10,
        }
        self.assertEqual(compute(payload), {"total": 22.00})

    def test_propagates_validation_error(self):
        payload = {"items": [{"sku": "A", "quantity": -1, "unit_price": 10.00}]}
        with self.assertRaises(ValueError):
            compute(payload)

    def test_rejects_negative_tax_rate(self):
        payload = {
            "items": [{"sku": "A", "quantity": 1, "unit_price": 10.00}],
            "tax_rate": -0.10,
        }
        with self.assertRaises(ValueError):
            compute(payload)


if __name__ == "__main__":
    unittest.main()
