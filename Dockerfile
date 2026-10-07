# Etapa 1: Construcción
FROM python:3.12-alpine AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Etapa 2: Imagen final para producción
FROM python:3.12-alpine
# Crear un usuario seguro que no es administrador
RUN adduser -D appuser
WORKDIR /app


COPY --from=builder /install /usr/local

COPY prestamos/ ./prestamos/

# Dar permisos al usuario seguro y activarlo
RUN chown -R appuser:appuser /app
USER appuser

# Exponer el puerto
EXPOSE 9000


HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9000/salud || exit 1


CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]