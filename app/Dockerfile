# ---Builder (dependency preparation)----

FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt ./
RUN pip install --upgrade pip && pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

# ---running image (application)----
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*
COPY main.py ./
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]