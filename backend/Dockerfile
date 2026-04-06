FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Piper binary
ARG PIPER_VERSION=1.2.0
RUN curl -L --fail --retry 3 -o /tmp/piper.tar.gz \
      "https://github.com/rhasspy/piper/releases/download/v${PIPER_VERSION}/piper_linux_x86_64.tar.gz" \
    && tar -xzf /tmp/piper.tar.gz -C /tmp \
    && cp /tmp/piper/piper /usr/local/bin/piper \
    && chmod +x /usr/local/bin/piper \
    && rm -rf /tmp/piper /tmp/piper.tar.gz

COPY backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY backend /app
RUN chmod +x /app/start.sh

ENV DJANGO_DEBUG=false \
    CORS_ALLOW_ALL=false \
    PIPER_EXECUTABLE=/usr/local/bin/piper \
    PIPER_MODEL_PATH=/tmp/piper/en_US-lessac-medium.onnx \
    PIPER_MODEL_PATH_EN=/tmp/piper/en_US-lessac-medium.onnx \
    PIPER_MODEL_PATH_SW=/tmp/piper/sw_CD-lanfrica-medium.onnx \
    PIPER_MODEL_URL_EN=https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx \
    PIPER_MODEL_CONFIG_URL_EN=https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json \
    PIPER_MODEL_URL_SW=https://huggingface.co/rhasspy/piper-voices/resolve/main/sw/sw_CD/lanfrica/medium/sw_CD-lanfrica-medium.onnx \
    PIPER_MODEL_CONFIG_URL_SW=https://huggingface.co/rhasspy/piper-voices/resolve/main/sw/sw_CD/lanfrica/medium/sw_CD-lanfrica-medium.onnx.json

EXPOSE 10000

CMD ["/app/start.sh"]
