# ⚡ Lesson 4: Image Optimization and Best Practices - Making Images Lean and Mean

*"Size matters - smaller, faster, safer images for the win!"*

Welcome to the optimization masterclass! You've learned to build images, now let's make them production-ready. In this lesson, we'll transform your images from bulky prototypes into lean, secure, lightning-fast containers that your infrastructure will love.

## 🎯 What You'll Learn

- How to dramatically reduce image sizes
- Security best practices for container images
- Layer caching strategies for faster builds
- Performance optimization techniques
- Tools and techniques for image analysis

## 📏 Why Image Size Matters

Think of Docker images like moving boxes:
- **Small boxes**: Easy to move, store, and ship
- **Large boxes**: Heavy, slow, expensive to transport

### The Real Impact of Image Size

```
Large Images (1GB+):
├── 💸 Higher storage costs
├── 🐌 Slower deployments
├── 🌐 More bandwidth usage
├── 🔒 Larger attack surface
└── 😤 Frustrated developers

Optimized Images (50-200MB):
├── 💰 Lower costs
├── 🚀 Faster deployments
├── 📱 Better user experience
├── 🛡️ Smaller attack surface
└── 😊 Happy teams
```

## 🔍 Image Analysis: Know Your Enemy

Before optimizing, let's understand what's taking up space in your images.

### Using `docker images` and `docker history`

```bash
# Check image sizes
docker images

# Analyze image layers
docker history your-image:tag

# Get detailed layer information
docker history --no-trunc your-image:tag
```

### Using `dive` - The Image Explorer

Install dive for detailed image analysis:

```bash
# Install dive (image analysis tool)
# On macOS
brew install dive

# On Linux
wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
sudo apt install ./dive_0.10.0_linux_amd64.deb

# Analyze an image
dive your-image:tag
```

## 🧪 Lab 1: Image Size Comparison

Let's build the same application with different optimization levels and compare!

### Step 1: Create Test Application

```bash
mkdir image-optimization-lab
cd image-optimization-lab
```

### Step 2: Create Application Files

```bash
# package.json
cat > package.json << 'EOF'
{
  "name": "optimization-demo",
  "version": "1.0.0",
  "description": "Image optimization demonstration",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21",
    "moment": "^2.29.4"
  },
  "devDependencies": {
    "nodemon": "^2.0.20",
    "jest": "^29.0.0"
  }
}
EOF

# server.js
cat > server.js << 'EOF'
const express = require('express');
const _ = require('lodash');
const moment = require('moment');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  const data = {
    message: 'Image Optimization Demo',
    timestamp: moment().format('YYYY-MM-DD HH:mm:ss'),
    randomNumbers: _.times(10, () => _.random(1, 100)),
    imageSize: 'Check docker images to see the size!',
    tips: [
      'Use multi-stage builds',
      'Choose smaller base images',
      'Remove unnecessary files',
      'Combine RUN commands',
      'Use .dockerignore'
    ]
  };
  
  res.json(data);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
EOF
```

### Step 3: Unoptimized Dockerfile (The Bad Example)

```bash
cat > Dockerfile.unoptimized << 'EOF'
# Unoptimized Dockerfile - DON'T DO THIS!
FROM node:16

# Install unnecessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    vim \
    git \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy everything (including node_modules if they exist)
COPY . .

# Install all dependencies (including dev)
RUN npm install

# Don't remove cache
# RUN npm cache clean --force

EXPOSE 3000
CMD ["npm", "start"]
EOF
```

### Step 4: Optimized Dockerfile (The Good Example)

```bash
cat > Dockerfile.optimized << 'EOF'
# Optimized Dockerfile - MUCH BETTER!
FROM node:16-alpine

# Install only necessary packages
RUN apk add --no-cache curl

WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY server.js ./

# Use non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000
CMD ["node", "server.js"]
EOF
```

### Step 5: Multi-Stage Optimized Dockerfile (The Best Example)

```bash
cat > Dockerfile.multistage << 'EOF'
# Multi-stage optimized Dockerfile - THE BEST!

# Stage 1: Dependencies
FROM node:16-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Production
FROM node:16-alpine AS production
RUN apk add --no-cache curl && \
    addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY server.js ./

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
EOF
```

### Step 6: Create .dockerignore

```bash
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log*
.git
.gitignore
README.md
Dockerfile*
.dockerignore
.env
coverage
.nyc_output
EOF
```

### Step 7: Build and Compare

```bash
# Build unoptimized version
docker build -f Dockerfile.unoptimized -t demo:unoptimized .

# Build optimized version
docker build -f Dockerfile.optimized -t demo:optimized .

# Build multi-stage version
docker build -f Dockerfile.multistage -t demo:multistage .

# Compare sizes
docker images | grep demo
```

You should see dramatic size differences!

### Step 8: Test All Versions

```bash
# Test unoptimized
docker run -d -p 3001:3000 --name demo-unopt demo:unoptimized

# Test optimized
docker run -d -p 3002:3000 --name demo-opt demo:optimized

# Test multi-stage
docker run -d -p 3003:3000 --name demo-multi demo:multistage

# Test all endpoints
curl http://localhost:3001
curl http://localhost:3002
curl http://localhost:3003
```

## 🛡️ Security Best Practices

### 1. Use Non-Root Users

```dockerfile
# Create and use non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

USER appuser
```

### 2. Scan for Vulnerabilities

```bash
# Use Docker Scout (built into Docker Desktop)
docker scout cves your-image:tag

# Use Trivy (open source scanner)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image your-image:tag
```

### 3. Use Minimal Base Images

```dockerfile
# Good: Minimal images
FROM node:16-alpine
FROM python:3.9-slim
FROM golang:1.19-alpine

# Avoid: Full images unless necessary
FROM node:16
FROM python:3.9
FROM ubuntu:20.04
```

## 🧪 Lab 2: Security Hardening

Let's create a security-hardened image!

### Step 1: Create Secure Application

```bash
mkdir secure-app
cd secure-app
```

### Step 2: Create Application

```bash
cat > package.json << 'EOF'
{
  "name": "secure-app",
  "version": "1.0.0",
  "description": "Security-hardened application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "helmet": "^6.0.0"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

app.get('/', (req, res) => {
  res.json({
    message: 'Security-hardened application',
    security: {
      user: process.getuid() !== 0 ? 'non-root' : 'root',
      helmet: 'enabled',
      timestamp: new Date().toISOString()
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Secure app running on port ${port}`);
});
EOF
```

### Step 3: Create Security-Hardened Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Security-hardened Dockerfile
FROM node:16-alpine

# Update packages and remove package manager cache
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies and clean up
RUN npm ci --only=production && \
    npm cache clean --force && \
    npm audit --audit-level=high

# Copy application code
COPY server.js ./

# Set proper ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Remove unnecessary capabilities and add security options
# (These would be used in docker run command)
# --cap-drop=ALL --cap-add=NET_BIND_SERVICE
# --read-only --tmpfs /tmp

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]
EOF
```

### Step 4: Build and Run Securely

```bash
# Build the secure image
docker build -t secure-app .

# Run with additional security options
docker run -d \
  --name secure-app \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /app/node_modules/.cache \
  -p 3000:3000 \
  secure-app

# Test the secure application
curl http://localhost:3000
```

## ⚡ Performance Optimization Techniques

### 1. Layer Caching Optimization

```dockerfile
# Good: Dependencies change less frequently
FROM node:16-alpine
WORKDIR /app

# Copy package files first
COPY package*.json ./
RUN npm ci --only=production

# Copy source code last
COPY . .
CMD ["npm", "start"]
```

### 2. Combine RUN Commands

```dockerfile
# Bad: Multiple layers
RUN apk update
RUN apk add curl
RUN apk add vim
RUN rm -rf /var/cache/apk/*

# Good: Single layer
RUN apk update && \
    apk add --no-cache curl vim && \
    rm -rf /var/cache/apk/*
```

### 3. Use Build Cache Mounts (BuildKit)

```dockerfile
# Enable BuildKit features
# syntax=docker/dockerfile:1

FROM node:16-alpine
WORKDIR /app
COPY package*.json ./

# Use cache mount for npm cache
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

COPY . .
CMD ["npm", "start"]
```

## 🧪 Lab 3: Performance-Optimized Build

Let's create a high-performance build setup!

### Step 1: Create Performance Test App

```bash
mkdir performance-app
cd performance-app
```

### Step 2: Create Application with Dependencies

```bash
cat > package.json << 'EOF'
{
  "name": "performance-app",
  "version": "1.0.0",
  "description": "Performance-optimized application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21",
    "axios": "^1.1.0",
    "compression": "^1.7.4"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const compression = require('compression');
const _ = require('lodash');

const app = express();
const port = process.env.PORT || 3000;

app.use(compression());

app.get('/', (req, res) => {
  const data = _.times(1000, (i) => ({
    id: i,
    value: _.random(1, 1000),
    timestamp: Date.now()
  }));
  
  res.json({
    message: 'Performance-optimized app',
    dataSize: data.length,
    sample: _.take(data, 5),
    buildOptimizations: [
      'Layer caching',
      'Multi-stage build',
      'Dependency optimization',
      'Compression enabled'
    ]
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Performance app running on port ${port}`);
});
EOF
```

### Step 3: Create Performance-Optimized Dockerfile

```bash
cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1
# Performance-optimized Dockerfile with BuildKit

# Stage 1: Dependencies
FROM node:16-alpine AS deps
WORKDIR /app

# Copy package files
COPY package*.json ./

# Use cache mount for faster builds
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production && \
    npm cache clean --force

# Stage 2: Production
FROM node:16-alpine AS production

# Install minimal runtime dependencies
RUN apk add --no-cache curl && \
    addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001 -G nodejs

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps --chown=appuser:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=appuser:nodejs server.js ./

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

CMD ["node", "server.js"]
EOF
```

### Step 4: Enable BuildKit and Build

```bash
# Enable BuildKit for better performance
export DOCKER_BUILDKIT=1

# Build with BuildKit
docker build -t performance-app .

# Time the build (rebuild to see cache benefits)
time docker build -t performance-app .

# Run the performance app
docker run -d -p 3000:3000 --name perf-app performance-app

# Test performance
curl http://localhost:3000
```

## 🔧 Advanced Optimization Tools

### 1. Docker Slim

Docker Slim can automatically optimize your images:

```bash
# Install docker-slim
curl -sL https://raw.githubusercontent.com/docker-slim/docker-slim/master/scripts/install-dockerslim.sh | sudo -E bash -

# Optimize an image
docker-slim build --target your-image:tag --tag your-image:slim
```

### 2. Multi-Architecture Builds

```bash
# Create multi-architecture images
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .
```

### 3. Image Squashing

```bash
# Squash layers (experimental)
docker build --squash -t myapp:squashed .
```

## 📊 Optimization Checklist

### Image Size Optimization ✅
- [ ] Use alpine or slim base images
- [ ] Multi-stage builds to remove build dependencies
- [ ] .dockerignore to exclude unnecessary files
- [ ] Combine RUN commands to reduce layers
- [ ] Remove package manager caches
- [ ] Install only production dependencies

### Security Optimization ✅
- [ ] Run as non-root user
- [ ] Use specific image tags, not 'latest'
- [ ] Scan for vulnerabilities regularly
- [ ] Keep base images updated
- [ ] Remove unnecessary packages and tools
- [ ] Use read-only filesystems when possible

### Performance Optimization ✅
- [ ] Order Dockerfile instructions by change frequency
- [ ] Use BuildKit for advanced caching
- [ ] Implement proper health checks
- [ ] Use compression in applications
- [ ] Optimize application startup time
- [ ] Monitor resource usage

## 🧪 Lab 4: Complete Optimization Challenge

Let's put it all together in one optimized application!

### Step 1: Create Ultimate Optimized App

```bash
mkdir ultimate-optimized-app
cd ultimate-optimized-app
```

### Step 2: Create Comprehensive Application

```bash
# package.json with minimal dependencies
cat > package.json << 'EOF'
{
  "name": "ultimate-optimized-app",
  "version": "1.0.0",
  "description": "Ultimate optimized Docker application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Minimal, efficient server
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Minimal middleware
app.use(express.json({ limit: '1mb' }));

app.get('/', (req, res) => {
  res.json({
    message: 'Ultimate Optimized Application',
    optimizations: {
      imageSize: 'Minimal alpine base',
      security: 'Non-root user, vulnerability scanned',
      performance: 'Multi-stage build, layer caching',
      dependencies: 'Production only, minimal set'
    },
    stats: {
      nodeVersion: process.version,
      uptime: process.uptime(),
      memory: process.memoryUsage().rss,
      pid: process.pid
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: Date.now() });
});

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Ultimate optimized app running on port ${port}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
EOF

# Comprehensive .dockerignore
cat > .dockerignore << 'EOF'
# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
jspm_packages/

# TypeScript v1 declaration files
typings/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test

# parcel-bundler cache
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
public

# Storybook build outputs
.out
.storybook-out

# Temporary folders
tmp/
temp/

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
node_modules/
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Git
.git
.gitignore

# Docker
Dockerfile*
docker-compose*
.dockerignore

# Documentation
README.md
docs/
*.md
EOF
```

### Step 3: Create Ultimate Dockerfile

```bash
cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1
# Ultimate optimized Dockerfile

# Stage 1: Dependencies
FROM node:16-alpine AS deps

# Security: Update packages
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

WORKDIR /app

# Copy package files for better caching
COPY package*.json ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production --no-optional && \
    npm cache clean --force

# Stage 2: Production
FROM node:16-alpine AS production

# Security: Update and create user
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 1001 -S nodejs && \
    adduser -S appuser -u 1001 -G nodejs

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps --chown=appuser:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=appuser:nodejs server.js ./

# Security: Switch to non-root user
USER appuser

# Performance: Expose port
EXPOSE 3000

# Reliability: Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["node", "server.js"]
EOF
```

### Step 4: Build and Test Ultimate App

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build the ultimate optimized image
docker build -t ultimate-app .

# Check the final size
docker images ultimate-app

# Run with security options
docker run -d \
  --name ultimate-app \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp \
  -p 3000:3000 \
  ultimate-app

# Test the application
curl http://localhost:3000
curl http://localhost:3000/health

# Check security
docker exec ultimate-app whoami
docker exec ultimate-app id
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Analyze image sizes and identify optimization opportunities
- [ ] Create multi-stage builds for minimal production images
- [ ] Implement security best practices in Dockerfiles
- [ ] Use layer caching effectively for faster builds
- [ ] Apply performance optimization techniques

## 🚀 What's Next?

Outstanding! You've mastered image optimization and security. In the final lesson of this module, we'll learn about [Publishing and Sharing Images](05-publishing-images.md) where you'll discover how to share your optimized creations with the world.

## 📝 Quick Reference Card

```dockerfile
# Optimization Best Practices
FROM node:16-alpine                    # Use minimal base images
RUN apk add --no-cache curl && \      # Combine commands
    rm -rf /var/cache/apk/*           # Clean up caches
COPY package*.json ./                  # Copy dependencies first
RUN npm ci --only=production          # Production dependencies only
COPY . .                              # Copy source last
USER 1001                             # Non-root user
HEALTHCHECK CMD curl -f http://localhost:3000/health
```

```bash
# Build optimization
export DOCKER_BUILDKIT=1              # Enable BuildKit
docker build --no-cache .             # Force rebuild
docker images                         # Check sizes
dive image:tag                        # Analyze layers
```

---

*"Optimization is not about perfection - it's about making smart trade-offs between size, security, and performance."* - Your images are now lean, mean, and production-ready! ⚡
