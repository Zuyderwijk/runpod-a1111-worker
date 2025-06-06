#!/usr/bin/env bash

echo "Deleting old Automatic1111 Web UI and venv"
rm -rf /workspace/stable-diffusion-webui
rm -rf /workspace/venv

echo "Cloning Automatic1111 WebUI"
cd /workspace
git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo "Updating system packages"
apt update && apt -y upgrade

echo "Installing essential Ubuntu packages"
apt -y install bc aria2

echo "Creating Python venv and activating"
cd stable-diffusion-webui
python3 -m venv /workspace/venv
source /workspace/venv/bin/activate

echo "Installing Torch and xformers for CUDA 11.8"
pip install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

echo "Running Automatic1111 install script"
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/install-automatic.py
python3 -m install-automatic --skip-torch-cuda-test

echo "Cloning only needed extensions"
# Uncomment extensions you really need
# git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

# echo "Installing ControlNet dependencies"
# cd extensions/sd-webui-controlnet
# pip install -r requirements.txt

echo "Installing RunPod Serverless dependencies"
cd /workspace/stable-diffusion-webui
pip install huggingface_hub runpod

echo "Make sure models directory exists"
mkdir -p /workspace/stable-diffusion-webui/models/Stable-diffusion

# **Copy your own models manually to the above folder before starting**
# So no aria2c downloads here, keeping storage use minimal!

echo "Creating logs directory"
mkdir -p /workspace/logs

echo "Downloading config files"
rm -f webui-user.sh config.json ui-config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/webui-user.sh
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/ui-config.json

echo "Setting up model symlinks to single source of truth"

# Define base model folder (inside runpod-a1111-worker)
MODEL_SRC="/workspace/runpod-a1111-worker/models"

# Define target model folders inside stable-diffusion-webui
MODEL_TARGET_BASE="/workspace/stable-diffusion-webui/models/Stable-diffusion"
MODEL_TARGET_LORA="/workspace/stable-diffusion-webui/models/Lora"
MODEL_TARGET_VAE="/workspace/stable-diffusion-webui/models/VAE"
MODEL_TARGET_CONTROLNET="/workspace/stable-diffusion-webui/models/ControlNet"

# Remove existing model folders (if any) and create symlinks
rm -rf "$MODEL_TARGET_BASE" "$MODEL_TARGET_LORA" "$MODEL_TARGET_VAE" "$MODEL_TARGET_CONTROLNET"

ln -s "$MODEL_SRC/Stable-diffusion" "$MODEL_TARGET_BASE"
ln -s "$MODEL_SRC/Lora" "$MODEL_TARGET_LORA"
ln -s "$MODEL_SRC/VAE" "$MODEL_TARGET_VAE"
ln -s "$MODEL_SRC/ControlNet" "$MODEL_TARGET_CONTROLNET"

echo "Symlinks created:"
ls -l /workspace/stable-diffusion-webui/models

echo "Starting Automatic1111 Web UI"
deactivate
export HF_HOME="/workspace"
cd /workspace/stable-diffusion-webui
./webui.sh -f