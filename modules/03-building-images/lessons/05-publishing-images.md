# 🚀 Lesson 5: Publishing and Sharing Images - Sharing Your Creations with the World

*"From local builds to global distribution - making your images available everywhere"*

Congratulations! You've built amazing, optimized Docker images. Now it's time to share them with the world. In this lesson, we'll explore how to publish your images to registries, implement proper tagging strategies, and make your containers available for others to use.

## 🎯 What You'll Learn

- How Docker registries work and why they're important
- Publishing images to Docker Hub and other registries
- Tagging strategies for version management
- Setting up automated builds and CI/CD integration
- Best practices for image distribution

## 🏪 Understanding Docker Registries

Think of Docker registries like app stores:
- **Docker Hub**: The main "App Store" for Docker images
- **Private Registries**: Your company's internal "Enterprise Store"
- **Cloud Registries**: AWS ECR, Google GCR, Azure ACR

### Registry Hierarchy

```
Registry (docker.io)
├── Namespace/Organization (your-username)
│   ├── Repository (my-app)
│   │   ├── Tag (latest)
│   │   ├── Tag (v1.0.0)
│   │   └── Tag (dev)
│   └── Repository (another-app)
└── Official Images (nginx, node, python)
```

## 🐳 Docker Hub: Your First Registry

Docker Hub is the default registry and the easiest place to start sharing your images.

### Setting Up Docker Hub

1. **Create Account**: Go to [hub.docker.com](https://hub.docker.com) and sign up
2. **Login Locally**: Use `docker login` to authenticate
3. **Create Repository**: Set up a new repository on Docker Hub

### Docker Hub Repository Types

```
Public Repositories:
├── 🌍 Visible to everyone
├── 🆓 Free (unlimited public repos)
├── 📥 Anyone can pull
└── 🔍 Searchable on Docker Hub

Private Repositories:
├── 🔒 Only you can see
├── 💰 Limited free private repos
├── 👥 Controlled access
└── 🏢 Good for proprietary code
```

## 🧪 Lab 1: Publishing Your First Image to Docker Hub

Let's publish one of your optimized images to Docker Hub!

### Step 1: Create a Publishable Application

```bash
mkdir publishable-app
cd publishable-app
```

### Step 2: Create Application Files

```bash
# package.json
cat > package.json << 'EOF'
{
  "name": "my-awesome-app",
  "version": "1.0.0",
  "description": "My first published Docker application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "keywords": ["docker", "nodejs", "example"],
  "author": "Your Name",
  "license": "MIT"
}
EOF

# server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: '🎉 Welcome to My Awesome Published App!',
    version: '1.0.0',
    description: 'This app is published on Docker Hub and available worldwide!',
    features: [
      'Optimized Docker image',
      'Published on Docker Hub',
      'Easy to deploy anywhere',
      'Production ready'
    ],
    usage: {
      pull: 'docker pull your-username/my-awesome-app',
      run: 'docker run -p 3000:3000 your-username/my-awesome-app'
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 My Awesome App running on port ${port}`);
  console.log(`🌍 Published and available worldwide!`);
});
EOF
```

### Step 3: Create Production Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Production-ready Dockerfile for publishing
FROM node:16-alpine

# Metadata for published image
LABEL maintainer="your-email@example.com" \
      version="1.0.0" \
      description="My awesome published Docker application" \
      org.opencontainers.image.source="https://github.com/your-username/my-awesome-app"

# Security and optimization
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application
COPY server.js ./

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["node", "server.js"]
EOF
```

### Step 4: Create README for Docker Hub

```bash
cat > README.md << 'EOF'
# My Awesome App

A simple, optimized Node.js application demonstrating Docker best practices.

## Features

- 🚀 Fast and lightweight (Alpine-based)
- 🔒 Security-hardened (non-root user)
- 📊 Health checks included
- 🏗️ Production-ready

## Quick Start

```bash
# Pull the image
docker pull your-username/my-awesome-app

# Run the container
docker run -d -p 3000:3000 --name awesome-app your-username/my-awesome-app

# Test the application
curl http://localhost:3000
```

## Environment Variables

- `PORT`: Application port (default: 3000)

## Health Check

The application includes a health check endpoint at `/health`.

## License

MIT License - see LICENSE file for details.
EOF
```

### Step 5: Login to Docker Hub

```bash
# Login to Docker Hub
docker login

# Enter your Docker Hub username and password when prompted
```

### Step 6: Build and Tag for Publishing

```bash
# Build the image with your Docker Hub username
# Replace 'your-username' with your actual Docker Hub username
docker build -t your-username/my-awesome-app:1.0.0 .

# Also tag as 'latest'
docker tag your-username/my-awesome-app:1.0.0 your-username/my-awesome-app:latest

# Verify the tags
docker images | grep my-awesome-app
```

### Step 7: Push to Docker Hub

```bash
# Push specific version
docker push your-username/my-awesome-app:1.0.0

# Push latest
docker push your-username/my-awesome-app:latest

# View your published image on Docker Hub
echo "Visit: https://hub.docker.com/r/your-username/my-awesome-app"
```

### Step 8: Test Your Published Image

```bash
# Remove local images to test pulling from registry
docker rmi your-username/my-awesome-app:1.0.0
docker rmi your-username/my-awesome-app:latest

# Pull from Docker Hub
docker pull your-username/my-awesome-app

# Run the pulled image
docker run -d -p 3000:3000 --name published-app your-username/my-awesome-app

# Test it works
curl http://localhost:3000
```

## 🏷️ Tagging Strategies

Proper tagging is crucial for managing image versions and deployments.

### Semantic Versioning

```bash
# Major.Minor.Patch versioning
docker tag myapp:latest myapp:1.0.0    # Specific version
docker tag myapp:latest myapp:1.0      # Minor version
docker tag myapp:latest myapp:1        # Major version
docker tag myapp:latest myapp:latest   # Latest stable
```

### Environment-Based Tagging

```bash
# Environment tags
docker tag myapp:1.0.0 myapp:dev       # Development
docker tag myapp:1.0.0 myapp:staging   # Staging
docker tag myapp:1.0.0 myapp:prod      # Production
```

### Git-Based Tagging

```bash
# Git commit-based tags
docker tag myapp:latest myapp:$(git rev-parse --short HEAD)
docker tag myapp:latest myapp:main-$(date +%Y%m%d)
```

## 🧪 Lab 2: Advanced Tagging and Multi-Version Publishing

Let's create a more sophisticated publishing workflow!

### Step 1: Create Versioned Application

```bash
mkdir versioned-app
cd versioned-app
```

### Step 2: Create Application with Version Support

```bash
# package.json with version
cat > package.json << 'EOF'
{
  "name": "versioned-app",
  "version": "2.1.0",
  "description": "Application demonstrating version management",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# server.js with version info
cat > server.js << 'EOF'
const express = require('express');
const packageJson = require('./package.json');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    name: packageJson.name,
    version: packageJson.version,
    description: packageJson.description,
    buildInfo: {
      buildDate: process.env.BUILD_DATE || 'unknown',
      gitCommit: process.env.GIT_COMMIT || 'unknown',
      imageTag: process.env.IMAGE_TAG || 'unknown'
    },
    versionHistory: [
      { version: '1.0.0', changes: ['Initial release'] },
      { version: '2.0.0', changes: ['Major refactor', 'New API'] },
      { version: '2.1.0', changes: ['Bug fixes', 'Performance improvements'] }
    ]
  });
});

app.get('/version', (req, res) => {
  res.json({ version: packageJson.version });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`${packageJson.name} v${packageJson.version} running on port ${port}`);
});
EOF
```

### Step 3: Create Build Script

```bash
cat > build.sh << 'EOF'
#!/bin/bash

# Get version from package.json
VERSION=$(node -p "require('./package.json').version")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
IMAGE_NAME="your-username/versioned-app"

echo "Building $IMAGE_NAME:$VERSION"

# Build with build args
docker build \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg GIT_COMMIT="$GIT_COMMIT" \
  --build-arg VERSION="$VERSION" \
  -t "$IMAGE_NAME:$VERSION" \
  -t "$IMAGE_NAME:latest" \
  .

echo "Built images:"
docker images | grep versioned-app
EOF

chmod +x build.sh
```

### Step 4: Create Advanced Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM node:16-alpine

# Build arguments
ARG BUILD_DATE
ARG GIT_COMMIT
ARG VERSION

# Labels with build info
LABEL maintainer="your-email@example.com" \
      version="$VERSION" \
      build-date="$BUILD_DATE" \
      git-commit="$GIT_COMMIT" \
      description="Versioned application demonstrating Docker publishing"

# Environment variables from build args
ENV BUILD_DATE=$BUILD_DATE \
    GIT_COMMIT=$GIT_COMMIT \
    IMAGE_TAG=$VERSION

# Security setup
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy application
COPY server.js ./

# Set ownership
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/version || exit 1

CMD ["node", "server.js"]
EOF
```

### Step 5: Build and Publish Multiple Versions

```bash
# Build the versioned image
./build.sh

# Create additional tags
docker tag your-username/versioned-app:2.1.0 your-username/versioned-app:2.1
docker tag your-username/versioned-app:2.1.0 your-username/versioned-app:2

# Push all versions
docker push your-username/versioned-app:2.1.0
docker push your-username/versioned-app:2.1
docker push your-username/versioned-app:2
docker push your-username/versioned-app:latest
```

## 🏢 Private and Enterprise Registries

### AWS Elastic Container Registry (ECR)

```bash
# Login to AWS ECR
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Tag for ECR
docker tag myapp:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest

# Push to ECR
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
```

### Google Container Registry (GCR)

```bash
# Configure Docker for GCR
gcloud auth configure-docker

# Tag for GCR
docker tag myapp:latest gcr.io/my-project/myapp:latest

# Push to GCR
docker push gcr.io/my-project/myapp:latest
```

### Azure Container Registry (ACR)

```bash
# Login to ACR
az acr login --name myregistry

# Tag for ACR
docker tag myapp:latest myregistry.azurecr.io/myapp:latest

# Push to ACR
docker push myregistry.azurecr.io/myapp:latest
```

## 🧪 Lab 3: Setting Up a Private Registry

Let's run our own private Docker registry!

### Step 1: Run a Local Registry

```bash
# Start a local registry
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  registry:2

# Verify it's running
curl http://localhost:5000/v2/
```

### Step 2: Push to Private Registry

```bash
# Tag image for private registry
docker tag your-username/my-awesome-app:latest localhost:5000/my-awesome-app:latest

# Push to private registry
docker push localhost:5000/my-awesome-app:latest

# List images in private registry
curl http://localhost:5000/v2/_catalog
```

### Step 3: Pull from Private Registry

```bash
# Remove local image
docker rmi localhost:5000/my-awesome-app:latest

# Pull from private registry
docker pull localhost:5000/my-awesome-app:latest

# Run the image
docker run -d -p 3001:3000 --name private-app localhost:5000/my-awesome-app:latest
```

## 🔄 Automated Builds and CI/CD

### GitHub Actions Example

```yaml
# .github/workflows/docker-publish.yml
name: Docker Build and Push

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: your-username/my-app
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
```

### Docker Hub Automated Builds

1. **Connect Repository**: Link your GitHub/Bitbucket repo to Docker Hub
2. **Configure Build Rules**: Set up automatic builds on push/tag
3. **Build Triggers**: Configure when builds should happen

## 📊 Best Practices for Publishing

### 1. Image Naming Conventions

```bash
# Good naming patterns
registry.com/organization/application:version
your-username/my-app:1.2.3
company.com/team/service:v2.1.0-alpine

# Avoid
my_app:latest
app:1
test:v1
```

### 2. Documentation

Always include:
- **README.md**: Usage instructions
- **Dockerfile**: Well-commented
- **CHANGELOG.md**: Version history
- **LICENSE**: Legal information

### 3. Security Scanning

```bash
# Scan before publishing
docker scout cves your-image:tag
trivy image your-image:tag

# Only publish clean images
```

### 4. Multi-Architecture Support

```bash
# Build for multiple architectures
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t your-username/my-app:latest \
  --push .
```

## 🧪 Lab 4: Complete Publishing Workflow

Let's create a complete, production-ready publishing workflow!

### Step 1: Create Production Application

```bash
mkdir production-publish-app
cd production-publish-app
```

### Step 2: Create Complete Application Structure

```bash
# Create directory structure
mkdir -p src docs

# package.json
cat > package.json << 'EOF'
{
  "name": "production-publish-app",
  "version": "1.0.0",
  "description": "Production-ready application with complete publishing workflow",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "test": "echo \"Tests would go here\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.0",
    "helmet": "^6.0.0",
    "compression": "^1.7.4"
  },
  "keywords": ["docker", "nodejs", "production", "example"],
  "author": "Your Name <your-email@example.com>",
  "license": "MIT"
}
EOF

# src/server.js
cat > src/server.js << 'EOF'
const express = require('express');
const helmet = require('helmet');
const compression = require('compression');
const packageJson = require('../package.json');

const app = express();
const port = process.env.PORT || 3000;

// Security and performance middleware
app.use(helmet());
app.use(compression());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    name: packageJson.name,
    version: packageJson.version,
    description: packageJson.description,
    status: 'Production Ready! 🚀',
    features: [
      'Security hardened with Helmet',
      'Performance optimized with compression',
      'Multi-architecture support',
      'Automated CI/CD pipeline',
      'Comprehensive documentation',
      'Health checks included'
    ],
    buildInfo: {
      buildDate: process.env.BUILD_DATE,
      gitCommit: process.env.GIT_COMMIT,
      version: process.env.VERSION
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: packageJson.version
  });
});

app.get('/metrics', (req, res) => {
  res.json({
    memory: process.memoryUsage(),
    uptime: process.uptime(),
    version: packageJson.version,
    nodeVersion: process.version
  });
});

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 ${packageJson.name} v${packageJson.version} running on port ${port}`);
  console.log(`🌍 Production-ready and published!`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
EOF

# Comprehensive README
cat > README.md << 'EOF'
# Production Publish App

A production-ready Node.js application demonstrating complete Docker publishing workflows.

## 🚀 Quick Start

```bash
docker run -d -p 3000:3000 your-username/production-publish-app
```

## 📋 Features

- ✅ Security hardened with Helmet
- ✅ Performance optimized with compression  
- ✅ Multi-architecture support (amd64, arm64)
- ✅ Health checks included
- ✅ Graceful shutdown handling
- ✅ Comprehensive monitoring endpoints

## 🔧 Usage

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Application port | `3000` |

### Endpoints

- `GET /` - Application information
- `GET /health` - Health check
- `GET /metrics` - Application metrics

### Docker Commands

```bash
# Pull latest version
docker pull your-username/production-publish-app

# Run with custom port
docker run -d -p 8080:3000 -e PORT=3000 your-username/production-publish-app

# Run with health checks
docker run -d --health-cmd="curl -f http://localhost:3000/health" your-username/production-publish-app
```

## 🏗️ Building

```bash
# Build locally
docker build -t your-username/production-publish-app .

# Build with version
docker build --build-arg VERSION=1.0.0 -t your-username/production-publish-app:1.0.0 .
```

## 📊 Monitoring

The application exposes metrics at `/metrics` for monitoring integration.

## 🔒 Security

- Runs as non-root user
- Security headers via Helmet
- Minimal attack surface
- Regular security scanning

## 📄 License

MIT License - see LICENSE file for details.
EOF

# LICENSE file
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2023 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

### Step 3: Create Production Dockerfile

```bash
cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1
# Production-ready multi-stage Dockerfile

# Build arguments
ARG NODE_VERSION=16
ARG BUILD_DATE
ARG GIT_COMMIT
ARG VERSION

# Stage 1: Dependencies
FROM node:${NODE_VERSION}-alpine AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Production
FROM node:${NODE_VERSION}-alpine AS production

# Comprehensive labels
LABEL maintainer="your-email@example.com" \
      version="${VERSION}" \
      build-date="${BUILD_DATE}" \
      git-commit="${GIT_COMMIT}" \
      description="Production-ready Node.js application" \
      org.opencontainers.image.title="Production Publish App" \
      org.opencontainers.image.description="Production-ready Node.js application with complete publishing workflow" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.licenses="MIT"

# Security and optimization
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    BUILD_DATE=${BUILD_DATE} \
    GIT_COMMIT=${GIT_COMMIT} \
    VERSION=${VERSION}

WORKDIR /app

# Copy dependencies
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules

# Copy application
COPY --chown=appuser:appgroup package*.json ./
COPY --chown=appuser:appgroup src/ ./src/

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
EOF
```

### Step 4: Create Build and Publish Scripts

```bash
# build-and-publish.sh
cat > build-and-publish.sh << 'EOF'
#!/bin/bash

set -e

# Configuration
IMAGE_NAME="your-username/production-publish-app"
VERSION=$(node -p "require('./package.json').version")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🏗️  Building $IMAGE_NAME:$VERSION"

# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build multi-architecture image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg GIT_COMMIT="$GIT_COMMIT" \
  --build-arg VERSION="$VERSION" \
  -t "$IMAGE_NAME:$VERSION" \
  -t "$IMAGE_NAME:latest" \
  --push \
  .

echo "✅ Successfully built and pushed:"
echo "   📦 $IMAGE_NAME:$VERSION"
echo "   📦 $IMAGE_NAME:latest"
echo "   🌍 Available on Docker Hub"
EOF

chmod +x build-and-publish.sh
```

### Step 5: Build and Publish

```bash
# Initialize buildx for multi-architecture builds
docker buildx create --use

# Build and publish
./build-and-publish.sh

# Test the published image
docker run -d -p 3000:3000 --name prod-app your-username/production-publish-app

# Test endpoints
curl http://localhost:3000
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Publish images to Docker Hub and other registries
- [ ] Implement proper tagging strategies
- [ ] Create comprehensive documentation for published images
- [ ] Set up automated builds and CI/CD pipelines
- [ ] Follow security best practices for published images

## 🎉 Module 3 Complete!

Congratulations! You've mastered the art of building Docker images. You can now:

✅ Write effective Dockerfiles from scratch  
✅ Use advanced techniques like multi-stage builds  
✅ Work with enterprise-grade Red Hat UBI images  
✅ Optimize images for size, security, and performance  
✅ Publish and share your images with the world  

## 🚀 What's Next?

You've completed Module 3! Head over to [Module 4: Networking and Storage](../../04-networking-storage/README.md) to learn how to make your containers communicate and persist data.

## 📝 Quick Reference Card

```bash
# Publishing workflow
docker login                                    # Login to registry
docker build -t username/app:1.0.0 .          # Build with tag
docker tag username/app:1.0.0 username/app:latest  # Additional tag
docker push username/app:1.0.0                # Push specific version
docker push username/app:latest               # Push latest

# Multi-architecture builds
docker buildx create --use                     # Setup buildx
docker buildx build --platform linux/amd64,linux/arm64 -t username/app --push .

# Registry operations
docker pull username/app:1.0.0                # Pull specific version
docker search username/app                    # Search for images
```

---

*"The best way to share knowledge is to make it accessible to everyone."* - Your images are now ready to make a difference in the world! 🌍
