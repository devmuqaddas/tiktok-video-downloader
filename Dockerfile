FROM python:3.11-slim

WORKDIR /app

# System dependencies for yt-dlp & ffmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create required directories
RUN mkdir -p uploads outputs static templates
RUN chmod 755 uploads outputs static templates

# Expose any port (Railway overrides with $PORT)
EXPOSE 5000

# Optional: remove or use dynamic HEALTHCHECK
# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
#    CMD curl -f http://localhost:$PORT/health || exit 1

# Run Gunicorn with UvicornWorker for ASGI app
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:$PORT", "app:app"]
