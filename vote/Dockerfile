FROM python:3.11-slim

# (Optional) build tools for some wheels
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# App deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app (includes templates/ and static/)
COPY . .

# Serve Flask via gunicorn on port 80
EXPOSE 80
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:80", "app:app"]
