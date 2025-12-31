#!/usr/bin/env python3

import os
import logging
from flask import Flask, request, abort, send_file
from pathlib import Path

# -------------------------------------------------
# Configuration
# -------------------------------------------------

APP_PORT = int(os.environ.get("APP_PORT", 8080))

# REQUIRED for POST (upload)
IMAGE_SECRET = os.environ.get("IMAGE_SECRET")

BASE_DIR = Path(__file__).resolve().parent
IMAGE_DIR = BASE_DIR / "images"

IMAGE_DIR.mkdir(exist_ok=True)

# -------------------------------------------------
# App setup
# -------------------------------------------------

logging.basicConfig(level=logging.INFO)
app = Flask(__name__)

# -------------------------------------------------
# Health check
# -------------------------------------------------

@app.route("/health", methods=["GET"])
def health():
    return "OK", 200

# -------------------------------------------------
# Helper: secret validation (POST only)
# -------------------------------------------------

def validate_secret():
    secret = request.headers.get("X-Image-Secret")
    if not IMAGE_SECRET or secret != IMAGE_SECRET:
        logging.warning("Invalid or missing X-Image-Secret header")
        abort(403)

# -------------------------------------------------
# GET image (PUBLIC – browser-friendly)
# -------------------------------------------------

@app.route("/image/<file_name>", methods=["GET"])
def get_image(file_name):
    image_path = IMAGE_DIR / f"{file_name}.png"

    if not image_path.exists():
        abort(404)

    return send_file(image_path, mimetype="image/png")

# -------------------------------------------------
# POST image (PROTECTED)
# -------------------------------------------------

@app.route("/image/<file_name>", methods=["POST"])
def save_image(file_name):
    validate_secret()

    if not request.data:
        abort(400, "No image data provided")

    image_path = IMAGE_DIR / f"{file_name}.png"

    with open(image_path, "wb") as f:
        f.write(request.data)

    logging.info("Saved image: %s", image_path.name)
    return "", 201

# -------------------------------------------------
# Root
# -------------------------------------------------

@app.route("/", methods=["GET"])
def index():
    return "Image Service is running", 200

# -------------------------------------------------
# Main
# -------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=APP_PORT)
