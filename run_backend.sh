#!/bin/bash

# Run the FastAPI server in the project environment (uv sync first)
uv run uvicorn backend.api.main:app --host 0.0.0.0 --port 8000 --reload
