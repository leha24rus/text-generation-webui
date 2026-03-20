#!/bin/bash
# start_v100.sh
# Важно: флаг --no_flash_attn предотвращает падение CUDA на Tesla V100 (sm_70)

export CUDA_HOME=$CONDA_PREFIX
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib:$CUDA_HOME/lib64:$LD_LIBRARY_PATH

if [ -d "$CUDA_HOME/targets/x86_64-linux/include" ]; then
    export CFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CFLAGS"
    export CXXFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CXXFLAGS"
    export CPATH="$CUDA_HOME/targets/x86_64-linux/include:$CPATH"
fi

export EXLLAMA_NOCOMPILE=1

echo ">>> Запуск Text-Generation-WebUI для Tesla V100..."
python server.py --loader ExLlamav3 "$@"
