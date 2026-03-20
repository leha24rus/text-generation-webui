#!/bin/bash
# start_v100.sh
# Важно: флаг --no_flash_attn предотвращает падение CUDA на Tesla V100 (sm_70)

echo ">>> Запуск Text-Generation-WebUI для Tesla V100..."
python server.py --loader ExLlamav3 "$@"
