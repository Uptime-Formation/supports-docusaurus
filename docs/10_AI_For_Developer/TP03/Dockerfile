FROM python:3.9-slim-buster

# Set metadata
LABEL maintainer="Alban" \
      org.opencontainers.image.title="excel-to-web" \
      org.opencontainers.image.description="Convertisseur Excel vers HTML" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.created="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      org.opencontainers.image.revision="<REVISION>" \
      org.opencontainers.image.vendor="RackFlow" \
      org.opencontainers.image.licenses="MIT"

# Set working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY script.py .

# Create a non-root user
RUN useradd -m nonroot && chown -R nonroot:nonroot /app
USER nonroot

# Set the default command to run the script
CMD ["python", "script.py"]
