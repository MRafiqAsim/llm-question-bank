#!/bin/bash

echo "================================================"
echo "Autonomous Question Bank - Interactive Startup Script"
echo "================================================"
echo ""
echo "Choose your setup:"
echo ""
echo "1) MLX (Local) - Fast, uses Apple Silicon GPU"
echo "   - Best for: Development on Mac M1/M2/M3"
echo "   - Speed: ⚡ Very Fast"
echo "   - Requirements: Apple Silicon Mac"
echo ""
echo "2) Docker with Ollama - Portable, runs anywhere"
echo "   - Best for: Testing portability, deployment"
echo "   - Speed: 🐢 Slower (CPU only)"
echo "   - Requirements: Docker Desktop"
echo ""
echo "3) OpenAI API - Cloud-based, high quality"
echo "   - Best for: Production, no local compute"
echo "   - Speed: ⚡ Fast"
echo "   - Requirements: OpenAI API key (costs money)"
echo ""

read -p "Enter your choice (1, 2, or 3): " choice

case $choice in
  1)
    echo ""
    echo "Starting QBank with MLX (Local)..."
    echo "================================================"
    echo ""

    # Check if MongoDB is running
    if ! docker ps | grep -q qbank-mongodb; then
      echo "Starting MongoDB..."
      docker run -d -p 27017:27017 --name qbank-mongodb mongo:7.0 2>/dev/null || docker start qbank-mongodb
      sleep 3
    else
      echo "✓ MongoDB already running"
    fi

    # Kill any process on ports
    echo "Checking ports..."
    lsof -ti:8000 | xargs kill -9 2>/dev/null || true
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true

    # Start backend with MLX
    echo ""
    echo "Starting backend with MLX..."
    cd "$(dirname "$0")"
    uv sync --extra mlx
    uv run uvicorn backend.api.main:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID=$!

    sleep 5

    # Start frontend
    echo "Starting frontend..."
    cd frontend && npm run dev &
    FRONTEND_PID=$!

    echo ""
    echo "================================================"
    echo "✅ QBank Started with MLX!"
    echo "================================================"
    echo ""
    echo "Access your application:"
    echo "  🌐 Frontend:    http://localhost:3000"
    echo "  🔧 Backend API: http://localhost:8000"
    echo "  📚 API Docs:    http://localhost:8000/docs"
    echo "  🗄️  MongoDB:     localhost:27017"
    echo ""
    echo "LLM Model: MLX (Meta-Llama-3-8B-Instruct-4bit)"
    echo ""
    echo "Press Ctrl+C to stop all services"
    echo ""

    # Wait for Ctrl+C
    trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT
    wait
    ;;

  2)
    echo ""
    echo "Starting QBank with Docker (Ollama)..."
    echo "================================================"
    echo ""

    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
      echo "❌ Error: Docker is not running!"
      echo "Please start Docker Desktop and try again."
      exit 1
    fi

    ./docker-start-with-ollama.sh
    ;;

  3)
    echo ""
    echo "Starting QBank with OpenAI API..."
    echo "================================================"
    echo ""

    # Check for API key
    if ! grep -q "OPENAI_API_KEY=" .env 2>/dev/null || grep -q "OPENAI_API_KEY=your" .env 2>/dev/null; then
      echo "⚠️  OpenAI API key not configured!"
      echo ""
      read -p "Enter your OpenAI API key: " api_key

      if [ -z "$api_key" ]; then
        echo "❌ Error: API key is required"
        exit 1
      fi

      # Update .env file
      if [ -f .env ]; then
        # Update existing file
        sed -i '' "s/LLM_PROVIDER=.*/LLM_PROVIDER=openai/" .env
        sed -i '' "s/MODEL_NAME=.*/MODEL_NAME=gpt-4o-mini/" .env
        sed -i '' "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$api_key/" .env
      else
        echo "❌ Error: .env file not found"
        exit 1
      fi
    fi

    # Check if MongoDB is running
    if ! docker ps | grep -q qbank-mongodb; then
      echo "Starting MongoDB..."
      docker run -d -p 27017:27017 --name qbank-mongodb mongo:7.0 2>/dev/null || docker start qbank-mongodb
      sleep 3
    else
      echo "✓ MongoDB already running"
    fi

    # Kill any process on ports
    echo "Checking ports..."
    lsof -ti:8000 | xargs kill -9 2>/dev/null || true
    lsof -ti:3000 | xargs kill -9 2>/dev/null || true

    # Start backend with OpenAI
    echo ""
    echo "Starting backend with OpenAI API..."
    cd "$(dirname "$0")"
    uv sync
    uv run uvicorn backend.api.main:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID=$!

    sleep 5

    # Start frontend
    echo "Starting frontend..."
    cd frontend && npm run dev &
    FRONTEND_PID=$!

    echo ""
    echo "================================================"
    echo "✅ QBank Started with OpenAI API!"
    echo "================================================"
    echo ""
    echo "Access your application:"
    echo "  🌐 Frontend:    http://localhost:3000"
    echo "  🔧 Backend API: http://localhost:8000"
    echo "  📚 API Docs:    http://localhost:8000/docs"
    echo "  🗄️  MongoDB:     localhost:27017"
    echo ""
    echo "LLM Model: OpenAI GPT-4o-mini"
    echo ""
    echo "Press Ctrl+C to stop all services"
    echo ""

    # Wait for Ctrl+C
    trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT
    wait
    ;;

  *)
    echo "❌ Invalid choice. Please run the script again and select 1, 2, or 3."
    exit 1
    ;;
esac
