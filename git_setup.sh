

echo "🔧 Setting up Git repository and branches"
echo "========================================="

# Check if we're in the bookmark-manager directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Please run from bookmark-manager root directory"
    exit 1
fi

echo ""
echo "1️⃣ Initializing Git repository..."

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.next/
out/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.tfplan

# Docker
.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs
*.log

# Database
*.db
*.sqlite3

# AWS
.aws/

# Secrets
secrets/
*.pem
*.key

# Coverage
htmlcov/
.coverage
coverage.xml
*.cover

# pytest
.pytest_cache/

# mypy
.mypy_cache/
EOF
    echo "✅ Created .gitignore"
fi

echo ""
echo "2️⃣ Setting up initial commit..."

# Stage all files
git add .

# Check if there are staged changes
if git diff --staged --quiet; then
    echo "⚠️  No changes to commit"
else
    # Make initial commit
    git commit -m "Initial commit: Personal Bookmark Manager

- FastAPI backend with health check endpoints
- Docker configuration for local development
- PostgreSQL database setup
- Basic project structure
- Authentication system (JWT)
- Bookmark CRUD operations
- Stage 1 CI pipeline configuration"
    echo "✅ Initial commit created"
fi

echo ""
echo "3️⃣ Setting up branches..."

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

# If we're not on main, create and switch to main
if [ "$CURRENT_BRANCH" != "main" ]; then
    git checkout -b main 2>/dev/null || git checkout main
    echo "✅ On main branch"
fi

# Create dev branch
git checkout -b dev 2>/dev/null || git checkout dev
echo "✅ Created/switched to dev branch"

# Switch back to main
git checkout main
echo "✅ Back on main branch"

echo ""
echo "4️⃣ Setting up GitHub repository connection..."

echo "📝 To connect to GitHub repository:"
echo "1. Create a new repository on GitHub (don't initialize with README)"
echo "2. Copy the repository URL"
echo "3. Run these commands:"
echo ""
echo "   git remote add origin <your-github-repo-url>"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "   git checkout dev"
echo "   git push -u origin dev"
echo ""

echo "✅ Git setup complete!"
echo ""
echo "📋 Current status:"
echo "=================="
git status
echo ""
echo "🌿 Available branches:"
git branch -a
echo ""
echo "🔗 Remote repositories:"
git remote -v || echo "No remote repositories configured yet"