#!/bin/bash
# setup_v100.sh

set -e

echo "=== Подготовка окружения Text-Generation-WebUI для Tesla V100 ==="

if ! command -v conda &> /dev/null; then
    echo "[!] Conda не найдена. Убедитесь, что вы активировали окружение."
    # Мы не завершаем со сбоем, возможно пользователь использует просто venv, но предупреждаем
fi

echo ">>> Удаление несовместимой версии exllamav3..."
pip uninstall exllamav3 -y || true

echo ">>> Подготовка к ручной сборке exllamav3 для Volta (sm_70)..."
if [ -d "exllamav3_src" ]; then
    rm -rf exllamav3_src
fi

git clone https://github.com/turboderp-org/exllamav3.git exllamav3_src
cd exllamav3_src

# Настройка переменных окружения для сборки cuda extensions под sm_70
if [ -z "$CUDA_HOME" ]; then
    export CUDA_HOME=/usr/local/cuda-12.1
fi

export PATH=$CUDA_HOME/bin:$PATH
export TORCH_CUDA_ARCH_LIST="7.0"
export MAX_JOBS=$(nproc)

echo ">>> Запуск компиляции nvcc (потребует времени)..."
pip install .

cd ..
rm -rf exllamav3_src

echo ">>> Обновление NumPy для совместимости квантованных тензоров (предотвращение overflow)..."
pip install numpy==2.2.6

echo "=== Готово! Теперь вы можете запускать WEB-UI через ./start_v100.sh ==="
