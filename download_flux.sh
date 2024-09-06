#!/bin/bash

# HuggingFace and CivitAI tokens
HUGGINGFACE_TOKEN="YOUR TOKEN HERE"
CIVITAI_TOKEN="YOUR TOKEN HERE"

# Base directory for ComfyUI models
BASE_DIR="ComfyUI/models"

# Ensure necessary directories exist
mkdir -p "$BASE_DIR/unet"
mkdir -p "$BASE_DIR/clip"
mkdir -p "$BASE_DIR/vae"
mkdir -p "$BASE_DIR/checkpoints"
mkdir -p "$BASE_DIR/upscale_models"
mkdir -p "$BASE_DIR/ultralytics/bbox"
mkdir -p "$BASE_DIR/ultralytics/segm"

# Function to download files with HuggingFace authorization header
download_huggingface() {
    local url=$1
    local output_path=$2
    echo "Downloading $url to $output_path"
    curl -L -H "Authorization: Bearer $HUGGINGFACE_TOKEN" "$url" -o "$output_path"
}

# Function to download files with CivitAI token
download_civitai() {
    local url=$1
    local output_path=$2
    echo "Downloading $url to $output_path"
    curl -L "${url}?token=$CIVITAI_TOKEN" -o "$output_path"
}

# FLUX downloads
download_huggingface "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors" "$BASE_DIR/unet/flux1-dev.sft"
download_huggingface "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" "$BASE_DIR/clip/t5xxl_fp16.safetensors"
download_huggingface "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" "$BASE_DIR/clip/clip_l.safetensors"
download_huggingface "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/vae/diffusion_pytorch_model.safetensors" "$BASE_DIR/vae/diffusion_pytorch_model.safetensors"
download_huggingface "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" "$BASE_DIR/vae/ae.sft"
download_huggingface "https://huggingface.co/XLabs-AI/flux-controlnet-depth-v3/resolve/main/flux-depth-controlnet-v3.safetensors" "$BASE_DIR/xlabs/controlnets/flux-depth-controlnet-v3.safetensors"

# Perfect skin. Perfect hands. Perfect eyes. (m/f)
download_civitai "https://civitai.com/api/download/models/732137" "$BASE_DIR/loras/FLUX_polyhedron_all_1300.safetensors"
download_civitai "https://civitai.com/api/download/models/732137" "$BASE_DIR/loras/flux_realism_lora.safetensors"

# Update security_level in config.ini file
CONFIG_FILE="ComfyUI/custom_nodes/ComfyUI-Manager/config.ini"
if [ -f "$CONFIG_FILE" ]; then
    echo "Updating security_level in $CONFIG_FILE"
    sed -i 's/security_level = normal/security_level = weak/' "$CONFIG_FILE"
else
    echo "Config file not found at $CONFIG_FILE, skipping update."
fi

echo "All models downloaded successfully."