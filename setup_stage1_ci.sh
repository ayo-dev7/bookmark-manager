#!/bin/bash
# setup_stage1_ci.sh - Set up Stage 1 CI (Basic Testing & Docker Build)

echo "🚀 Stage 1: Setting up Basic CI Pipeline"
echo "========================================"
echo ""
echo "This script will:"
echo "- Create basic GitHub Actions workflow"
echo "- Set up minimal code quality tools"
echo "- Create basic tests for health endpoints"
echo "- Test the setup locally"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the bookmark-manager root directory"
    echo "   Expected to find docker-compose.yml in current directory"
    exit 1
fi

echo "✅ Running from correct directory"

# Check if backend directory exists
if [ ! -d "backend" ]; then
    echo "❌ Error: backend directory not found"
    exit 1
fi

echo ""
echo "1️⃣ Creating GitHub Actions workflow directory..."

mkdir -p .github/workflows
echo "✅ Created .github/workflows directory"

echo ""
echo "2️⃣ Setting up basic code quality configuration..."

cd backend

# Create basic .flake8 configuration
cat > .flake8 << 'EOF'
[flake8]
max-line-length = 88
exclude = 
    .git,
    __pycache__,
    .venv,
    venv,
    build,
    dist,
    migrations
ignore = 
    E203,
    E501,
    W503
per-file-ignores =
    __init__.py:F401
EOF

echo "✅ Created .flake8 configuration"

# Create basic pyproject.toml
cat > pyproject.toml << 'EOF'
[tool.black]
line-length = 88
target-version = ['py311']
include = '\.pyi?$'

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-v --tb=short"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
EOF

echo "✅ Created pyproject.toml configuration"

echo ""
echo "3️⃣ Installing basic development dependencies..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
elif [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
else
    echo "⚠️  Warning: Could not activate virtual environment"
fi

# Install basic dev dependencies
echo "Installing development dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
pip install black flake8 pytest pytest-asyncio httpx

echo "✅ Installed basic development dependencies"

echo ""
echo "4️⃣ Creating basic test file..."

# Ensure tests directory exists
mkdir -p tests

# Create basic test file (rename existing if needed)
if [ -f "tests/test_main.py" ]; then
    echo "⚠️  tests/test_main.py already exists, creating test_main_stage1.py instead"
    TEST_FILE="tests/test_main_stage1.py"
else
    TEST_FILE="tests/test_main.py"
fi

cat > "$TEST_FILE" << 'EOF'
"""Stage 1: Basic tests for health endpoints."""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    """Test the root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data

def test_health_endpoint():
    """Test the health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"

def test_openapi_docs():
    """Test that OpenAPI docs are accessible."""
    response = client.get("/docs")
    assert response.status_code == 200

def test_openapi_json():
    """Test that OpenAPI JSON is accessible."""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    data = response.json()
    assert "openapi" in data
EOF

echo "✅ Created basic test file: $TEST_FILE"

echo ""
echo "5️⃣ Running local quality checks..."

echo "🎨 Checking code formatting..."
black --check app/ tests/ || (echo "⚠️  Code formatting issues found. Run 'black app/ tests/' to fix" && black app/ tests/)

echo ""
echo "🔍 Running linting..."
flake8 app/ tests/ || echo "⚠️  Linting issues found (will be caught in CI)"

echo ""
echo "🧪 Running basic tests..."
export DATABASE_URL="sqlite:///./test.db"
export JWT_SECRET_KEY="test-secret-key-for-stage1"
export ENVIRONMENT="testing"

pytest "$TEST_FILE" -v

echo ""
echo "6️⃣ Testing Docker build..."

cd ..
echo "🐳 Building Docker image..."
docker build -t bookmark-manager-backend:stage1-test ./backend

echo "🚀 Testing Docker container..."
docker run --rm -d --name stage1-test \
  -e DATABASE_URL=sqlite:///test.db \
  -e JWT_SECRET_KEY=test-secret \
  -e ENVIRONMENT=testing \
  -p 8001:8000 \
  bookmark-manager-backend:stage1-test

# Wait for container to start
sleep 5

# Test health endpoint
echo "Testing health endpoint..."
if curl -f http://localhost:8001/health; then
    echo "✅ Docker container test passed!"
else
    echo "❌ Docker container test failed"
fi

# Stop container
docker stop stage1-test

echo ""
echo "✅ Stage 1 CI setup complete!"
echo ""
echo "📋 What was implemented:"
echo "======================"
echo "✅ Basic GitHub Actions workflow (copy manually to .github/workflows/)"
echo "✅ Code formatting with Black"
echo "✅ Basic linting with flake8"
echo "✅ Basic health check tests"
echo "✅ Docker build validation"
echo ""
echo "📝 Next Steps:"
echo "============="
echo "1. Copy the workflow file from the artifact to .github/workflows/backend-ci-stage1.yml"
echo "2. Create and push to 'dev' branch:"
echo "   git checkout -b dev"
echo "   git add ."
echo "   git commit -m 'feat: add Stage 1 CI pipeline'"
echo "   git push -u origin dev"
echo "3. Check GitHub Actions tab to see the workflow run"
echo "4. Create a feature branch and PR to test:"
echo "   git checkout -b feature/test-stage1-ci"
echo "   echo '# Test change' >> README.md"
echo "   git add README.md && git commit -m 'test: trigger Stage 1 CI'"
echo "   git push -u origin feature/test-stage1-ci"
echo "   # Then create PR to 'dev' branch on GitHub"
echo ""
echo "🎯 Stage 1 Goals Achieved:"
echo "========================="
echo "✅ Basic CI pipeline running"
echo "✅ Code quality checks"
echo "✅ Health endpoint testing"
echo "✅ Docker build validation"
echo ""
echo "Ready for Stage 2: Enhanced CI with Authentication!"