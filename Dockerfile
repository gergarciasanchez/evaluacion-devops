
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Crear usuario y grupo sin privilegios
RUN groupadd --system django && \
    useradd --system --gid django --create-home django && \
    mkdir -p /data && \
    chown django:django /data

# Copiar el código de la aplicación
COPY --chown=django:django . .

# Ejecutar como usuario no root
USER django

EXPOSE 8000

# Verificar disponibilidad de la API
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/api/users/', timeout=3)" || exit 1

# Aplicar migraciones e iniciar Django
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

