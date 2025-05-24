#!/bin/bash

echo "📦 Downloading base model..."
mkdir -p models/Stable-diffusion
wget --header="Authorization: Bearer $HF_TOKEN" \
  https://huggingface.co/SouthDistrict/storybook-models/resolve/main/Stable-diffusion/whimsical_watercolor.safetensors \
  -O models/Stable-diffusion/whimsical_watercolor.safetensors

echo "🎨 Downloading LoRA models..."
mkdir -p models/Lora

for name in 3d_animation block_world clay_animation geometric paper_cutout picture_book soft_anime; do
  echo "→ Downloading $name..."
  wget --header="Authorization: Bearer $HF_TOKEN" \
    https://huggingface.co/SouthDistrict/storybook-models/resolve/main/Lora/$name.safetensors \
    -O models/Lora/$name.safetensors
done

echo "✅ All models downloaded."