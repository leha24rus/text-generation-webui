# NVIDIA Tesla V100 Support for Text-Generation-WebUI

Этот форк включает в себя скрипты автоматизации для работы библиотеки `exllamav3` на ускорителях микроархитектуры Volta (`sm_70`), таких как Tesla V100.
По умолчанию, `oobabooga` использует предкомпилированные пакеты (wheels), которые содержат бинарный код только для более новых архитектур (Turing, Ampere, Ada), а также активирует FlashAttention, что приводит к сбоям на V100.

## Как запустить на Linux:

1. Установите систему и драйверы CUDA (желательно 12.1). Установите `conda`.
2. Клонируйте репозиторий и установите базовые зависимости.
   ```bash
   conda create -n textgen python=3.10
   conda activate textgen
   pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
   cd text-generation-webui
   pip install -r requirements.txt
   ```
3. Сделайте bash скрипты исполняемыми:
   ```bash
   chmod +x setup_v100.sh start_v100.sh
   ```
4. Выполните скрипт сборки. Он удалит стандартный пакет exllama, загрузит исходники, скомпилирует их под `sm_70` и обновит `numpy`.
   ```bash
   ./setup_v100.sh
   ```
5. Запускайте сервер специально адаптированным скриптом:
   ```bash
   ./start_v100.sh
   ```
