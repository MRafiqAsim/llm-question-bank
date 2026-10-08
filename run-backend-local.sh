#!/bin/bash
# Run Backend Locally with MLX (Apple Silicon)
# This script runs the FastAPI backend on your Mac using MLX

echo "🚀 Starting QBank Backend with MLX..."
echo ""
echo "Provider: MLX (Apple Silicon)"
echo "Model: Meta-Llama-3-8B-Instruct-4bit"
echo "Port: 8000"
echo ""

# Install dependencies including MLX
uv sync --extra mlx

# Create necessary directories
mkdir -p uploads extracted_text generated_questions models

# Start FastAPI server
echo "Starting FastAPI server..."
uv run uvicorn backend.api.main:app --reload --host 0.0.0.0 --port 8000
