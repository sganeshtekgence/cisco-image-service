FROM python:3.10-slim

# -----------------------------
# Security: non-root user
# -----------------------------
RUN useradd -m appuser

# -----------------------------
# Working directory
# -----------------------------
WORKDIR /app

# -----------------------------
# Install dependencies
# -----------------------------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# -----------------------------
# Copy application code
# -----------------------------
COPY app.py .
RUN mkdir images && chown -R appuser:appuser /app

# -----------------------------
# Runtime configuration
# -----------------------------
USER appuser

ENV APP_PORT=8080
EXPOSE 8080

# -----------------------------
# Healthcheck (ECS-friendly)
# -----------------------------
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# -----------------------------
# Start app
# -----------------------------
CMD ["python", "app.py"]
