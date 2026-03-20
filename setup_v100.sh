#!/bin/bash
# setup_v100.sh

set -e
unset EXLLAMA_NOCOMPILE

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

echo ">>> Патчинг зависимостей (Удаление flash_attn и понижение требований torch)..."
sed -i 's/"torch>=2.6.0",/"torch>=2.4.0",/g' setup.py || true
sed -i '/flash_attn/d' setup.py || true
sed -i '/flash_attn/d' requirements.txt || true

echo ">>> Патчинг компилятора (Разрешение bfloat16/half конвертаций на sm_70)..."
sed -i 's/"-lineinfo", "-O3"/"-lineinfo", "-O3", "-U__CUDA_NO_BFLOAT16_CONVERSIONS__", "-U__CUDA_NO_HALF_CONVERSIONS__", "-U__CUDA_NO_HALF_OPERATORS__", "-U__CUDA_NO_HALF2_OPERATORS__"/g' setup.py || true

# Настройка переменных окружения для сборки cuda extensions под sm_70
if [ -z "$CUDA_HOME" ]; then
    export CUDA_HOME=/usr/local/cuda-12.1
fi

export PATH=$CUDA_HOME/bin:$PATH

if [ -d "$CUDA_HOME/targets/x86_64-linux/include" ]; then
    export CFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CFLAGS"
    export CXXFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CXXFLAGS"
    export CPATH="$CUDA_HOME/targets/x86_64-linux/include:$CPATH"
fi

export TORCH_CUDA_ARCH_LIST="7.0"
export MAX_JOBS=$(nproc)

echo ">>> Запуск компиляции nvcc (потребует времени)..."
pip install --no-cache-dir .

cd ..
rm -rf exllamav3_src

echo ">>> Обновление NumPy для совместимости квантованных тензоров (предотвращение overflow)..."
pip install numpy==2.2.6

echo "=== Готово! Теперь вы можете запускать WEB-UI через ./start_v100.sh ==="
