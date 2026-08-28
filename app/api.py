"""Minimal HTTP wrapper over the cart module.

Standard library only, on purpose: the repository stays dependency-free, so
`copilot-setup-steps.yml` has nothing to install and the container image needs
no package manager at build time.
"""

import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

from app.cart import CartItem, calculate_total


def compute(payload: dict) -> dict:
    items = [
        CartItem(
            sku=str(i["sku"]),
            quantity=int(i["quantity"]),
            unit_price=float(i["unit_price"]),
        )
        for i in payload.get("items", [])
    ]
    tax_rate = float(payload.get("tax_rate", 0.0))
    return {"total": calculate_total(items, tax_rate=tax_rate)}


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, body: dict) -> None:
        raw = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        if self.path == "/healthz":
            self._send(200, {"status": "ok"})
        else:
            self._send(404, {"error": "not found"})

    def do_POST(self):
        if self.path != "/total":
            self._send(404, {"error": "not found"})
            return
        length = int(self.headers.get("Content-Length", 0))
        try:
            payload = json.loads(self.rfile.read(length) or b"{}")
            self._send(200, compute(payload))
        except (ValueError, KeyError, TypeError) as exc:
            self._send(400, {"error": str(exc)})

    def log_message(self, *args):
        pass


def main():
    port = int(os.environ.get("PORT", "8000"))
    HTTPServer(("0.0.0.0", port), Handler).serve_forever()


if __name__ == "__main__":
    main()
