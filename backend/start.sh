#!/usr/bin/env bash
set -euo pipefail

cd /app

mkdir -p /var/data/piper /var/data/media /var/data/static

: "${PIPER_MODEL_PATH_EN:=/tmp/piper/en_US-lessac-medium.onnx}"
: "${PIPER_MODEL_PATH_SW:=/tmp/piper/sw_CD-lanfrica-medium.onnx}"
: "${PIPER_MODEL_URL_EN:=https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx}"
: "${PIPER_MODEL_CONFIG_URL_EN:=https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json}"
: "${PIPER_MODEL_URL_SW:=https://huggingface.co/rhasspy/piper-voices/resolve/main/sw/sw_CD/lanfrica/medium/sw_CD-lanfrica-medium.onnx}"
: "${PIPER_MODEL_CONFIG_URL_SW:=https://huggingface.co/rhasspy/piper-voices/resolve/main/sw/sw_CD/lanfrica/medium/sw_CD-lanfrica-medium.onnx.json}"

mkdir -p "$(dirname "${PIPER_MODEL_PATH_EN}")" "$(dirname "${PIPER_MODEL_PATH_SW}")"

# Download Piper models + config at runtime if missing.
if [ ! -f "${PIPER_MODEL_PATH_EN}" ]; then
  echo "Downloading English Piper model..."
  curl -L --fail --retry 3 -o "${PIPER_MODEL_PATH_EN}" "${PIPER_MODEL_URL_EN}"
fi
if [ ! -f "${PIPER_MODEL_PATH_EN}.json" ]; then
  echo "Downloading English Piper config..."
  curl -L --fail --retry 3 -o "${PIPER_MODEL_PATH_EN}.json" "${PIPER_MODEL_CONFIG_URL_EN}"
fi
if [ ! -f "${PIPER_MODEL_PATH_SW}" ]; then
  echo "Downloading Swahili Piper model..."
  curl -L --fail --retry 3 -o "${PIPER_MODEL_PATH_SW}" "${PIPER_MODEL_URL_SW}"
fi
if [ ! -f "${PIPER_MODEL_PATH_SW}.json" ]; then
  echo "Downloading Swahili Piper config..."
  curl -L --fail --retry 3 -o "${PIPER_MODEL_PATH_SW}.json" "${PIPER_MODEL_CONFIG_URL_SW}"
fi

python manage.py migrate --noinput

# collectstatic may be a no-op now, but keeps deployment future-proof.
python manage.py collectstatic --noinput || true

exec gunicorn config.wsgi:application --bind 0.0.0.0:${PORT:-10000} --workers 2 --threads 4 --timeout 180
