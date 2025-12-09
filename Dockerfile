# ==== Stage 1 : build (compilation des dépendances) ====
FROM python:3.11-slim AS builder

# Installer uniquement les dépendances nécessaires pour compiler (ex : lxml)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc \
       libxml2-dev libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY requirements.txt .

# Installer les dépendances dans un dossier isolé (sans cache)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ==== Stage 2 : image finale, durcie ====
FROM python:3.11-slim

# Créer un utilisateur non-root
RUN useradd -m appuser

WORKDIR /app

# Copier les dépendances pré-compilées depuis le builder
COPY --from=builder /install /usr/local

# Copier l'application (avec permissions correctes)
COPY --chown=appuser:appuser . /app

# Passer en utilisateur non-root
USER appuser

# Exposer le port de l'app
EXPOSE 4000

# Commande de lancement
CMD ["python", "main.py"]