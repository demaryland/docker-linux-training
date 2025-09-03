# 🚀 Lesson 2: Advanced Dockerfile Techniques - Mastering the Art

*"From basic recipes to gourmet container cuisine"*

Welcome back, Docker chef! You've mastered the basics of Dockerfiles, and now it's time to level up your skills. In this lesson, we'll explore advanced techniques that will make your images faster, smaller, and more professional.

## 🎯 What You'll Learn

- Multi-stage builds for optimization
- Build arguments and environment variables
- Advanced COPY techniques and file permissions
- Layer optimization strategies
- Professional Dockerfile patterns

## 🏗️ Multi-Stage Builds: The Game Changer

Multi-stage builds are like having multiple kitchens - you can prepare ingredients in one kitchen and serve the final dish from another, cleaner kitchen.

### The Problem: Bloated Images

Imagine building a Node.js application:

```dockerfile
# Traditional approach - everything in one stage
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

**Problem**: This image includes:
- Build tools (npm, compilers)
- Source code
- Development dependencies
- Build artifacts

**Result**: A huge image (500MB+) when you only need the final app!

### The Solution: Multi-Stage Build

```dockerfile
# Stage 1: Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production stage
FROM node:16-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["npm", "start"]
```

**Benefits**:
- Smaller final image (100MB vs 500MB)
- No build tools in production
- Cleaner, more secure

## 🧪 Lab 1: Multi-Stage Build in Action

Let's build a React application with multi-stage builds!

### Step 1: Create React Project Structure

```bash
mkdir react-docker-app
cd react-docker-app
```

### Step 2: Create package.json

```bash
cat > package.json << 'EOF'
{
  "name": "react-docker-app",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF
```

### Step 3: Create public/index.html

```bash
mkdir public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>React Docker App</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF
```

### Step 4: Create src/index.js

```bash
mkdir src
cat > src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
EOF
```

### Step 5: Create src/App.js

```bash
cat > src/App.js << 'EOF'
import React from 'react';

function App() {
  return (
    <div style={{
      textAlign: 'center',
      padding: '50px',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      minHeight: '100vh',
      color: 'white',
      fontFamily: 'Arial, sans-serif'
    }}>
      <div style={{
        background: 'rgba(255,255,255,0.1)',
        padding: '40px',
        borderRadius: '15px',
        display: 'inline-block',
        backdropFilter: 'blur(10px)'
      }}>
        <h1>🚀 React + Docker Multi-Stage Build!</h1>
        <p>This React app was built using advanced Docker techniques!</p>
        <div style={{ marginTop: '30px' }}>
          <h3>✨ Features:</h3>
          <ul style={{ listStyle: 'none', padding: 0 }}>
            <li>📦 Multi-stage build</li>
            <li>🏗️ Optimized for production</li>
            <li>🔒 Secure and minimal</li>
            <li>⚡ Lightning fast</li>
          </ul>
        </div>
      </div>
    </div>
  );
}

export default App;
EOF
```

### Step 6: Create Multi-Stage Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Stage 1: Build the React application
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies)
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve the application with nginx
FROM nginx:alpine AS production

# Copy built application from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# nginx starts automatically
CMD ["nginx", "-g", "daemon off;"]
EOF
```

### Step 7: Build and Test

```bash
# Build the multi-stage image
docker build -t react-multistage .

# Run the container
docker run -d -p 8080:80 --name react-app react-multistage

# Check the image size
docker images react-multistage
```

Visit `http://localhost:8080` to see your optimized React app!

### Step 8: Compare Image Sizes

```bash
# Check the size difference
docker images | grep -E "(react-multistage|node)"
```

You'll see the multi-stage image is much smaller than a full Node.js image!

## 🔧 Build Arguments (ARG): Customizable Builds

Build arguments let you customize your image at build time - like choosing ingredients for your recipe.

### Basic ARG Usage

```dockerfile
# Define build argument with default value
ARG NODE_VERSION=16
ARG APP_ENV=production

# Use the argument
FROM node:${NODE_VERSION}-alpine

# Set environment variable from build arg
ENV NODE_ENV=${APP_ENV}

WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

### Building with Custom Arguments

```bash
# Use default values
docker build -t myapp .

# Override arguments
docker build --build-arg NODE_VERSION=18 --build-arg APP_ENV=development -t myapp:dev .
```

## 🧪 Lab 2: Flexible Build Arguments

Let's create a Dockerfile that can build different versions of an application!

### Step 1: Create Flexible Node.js App

```bash
mkdir flexible-docker-app
cd flexible-docker-app
```

### Step 2: Create package.json

```bash
cat > package.json << 'EOF'
{
  "name": "flexible-docker-app",
  "version": "1.0.0",
  "description": "Flexible Docker build example",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF
```

### Step 3: Create server.js

```bash
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
const appVersion = process.env.APP_VERSION || '1.0.0';

app.get('/', (req, res) => {
  res.json({
    message: 'Flexible Docker Build Demo!',
    environment: nodeEnv,
    version: appVersion,
    nodeVersion: process.version,
    timestamp: new Date().toISOString(),
    features: nodeEnv === 'development' ? ['hot-reload', 'debug-mode'] : ['optimized', 'production-ready']
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', environment: nodeEnv });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${port} in ${nodeEnv} mode`);
});
EOF
```

### Step 4: Create Flexible Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Build arguments with defaults
ARG NODE_VERSION=16
ARG APP_ENV=production
ARG APP_VERSION=1.0.0
ARG INSTALL_DEV_DEPS=false

# Use the Node version argument
FROM node:${NODE_VERSION}-alpine

# Set environment variables from build args
ENV NODE_ENV=${APP_ENV}
ENV APP_VERSION=${APP_VERSION}
ENV PORT=3000

# Install system dependencies based on environment
RUN if [ "$APP_ENV" = "development" ]; then \
        apk add --no-cache curl vim; \
    fi

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies conditionally
RUN if [ "$INSTALL_DEV_DEPS" = "true" ] || [ "$APP_ENV" = "development" ]; then \
        npm install; \
    else \
        npm install --only=production; \
    fi

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Use different commands based on environment
CMD if [ "$NODE_ENV" = "development" ]; then \
        npm run dev; \
    else \
        npm start; \
    fi
EOF
```

### Step 5: Build Different Versions

```bash
# Production build (default)
docker build -t flexible-app:prod .

# Development build
docker build \
  --build-arg APP_ENV=development \
  --build-arg INSTALL_DEV_DEPS=true \
  --build-arg APP_VERSION=1.0.0-dev \
  -t flexible-app:dev .

# Different Node.js version
docker build \
  --build-arg NODE_VERSION=18 \
  --build-arg APP_VERSION=2.0.0 \
  -t flexible-app:node18 .
```

### Step 6: Test Different Builds

```bash
# Test production build
docker run -d -p 3001:3000 --name app-prod flexible-app:prod

# Test development build
docker run -d -p 3002:3000 --name app-dev flexible-app:dev

# Check the differences
curl http://localhost:3001
curl http://localhost:3002
```

## 🔐 Advanced COPY Techniques

### COPY vs ADD

```dockerfile
# COPY: Simple file copying (preferred)
COPY src/ /app/src/
COPY package.json /app/

# ADD: Has extra features (use sparingly)
ADD https://example.com/file.tar.gz /tmp/    # Can download URLs
ADD archive.tar.gz /app/                     # Auto-extracts archives
```

**Best Practice**: Use COPY unless you specifically need ADD's features.

### Setting File Permissions

```dockerfile
# Copy and set ownership
COPY --chown=node:node package*.json ./
COPY --chown=1000:1000 . /app/

# Set permissions after copying
COPY . /app/
RUN chown -R node:node /app && chmod -R 755 /app
```

### Copying from Previous Stages

```dockerfile
# Copy from a specific stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy from another image
COPY --from=nginx:alpine /etc/nginx/nginx.conf /etc/nginx/
```

## ⚡ Layer Optimization Strategies

### 1. Combine RUN Commands

```dockerfile
# Bad: Creates multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get clean

# Good: Single layer
RUN apt-get update && \
    apt-get install -y curl vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 2. Order Instructions by Change Frequency

```dockerfile
# Good: Least changing to most changing
FROM node:16-alpine
WORKDIR /app

# Package files change less frequently
COPY package*.json ./
RUN npm install

# Source code changes more frequently
COPY . .
RUN npm run build

CMD ["npm", "start"]
```

### 3. Use .dockerignore Effectively

```bash
cat > .dockerignore << 'EOF'
# Version control
.git
.gitignore

# Dependencies
node_modules
npm-debug.log*

# Build outputs
dist
build
*.log

# IDE files
.vscode
.idea
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Environment files
.env
.env.local
.env.*.local

# Documentation
README.md
docs/
*.md
EOF
```

## 🧪 Lab 3: Optimized Production Dockerfile

Let's create a highly optimized Dockerfile using all our advanced techniques!

### Step 1: Create Optimized Project

```bash
mkdir optimized-docker-app
cd optimized-docker-app
```

### Step 2: Create Application Files

```bash
# package.json
cat > package.json << 'EOF'
{
  "name": "optimized-docker-app",
  "version": "1.0.0",
  "description": "Highly optimized Docker application",
  "main": "dist/server.js",
  "scripts": {
    "build": "babel src --out-dir dist",
    "start": "node dist/server.js",
    "dev": "nodemon --exec babel-node src/server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "compression": "^1.7.4",
    "helmet": "^6.0.0"
  },
  "devDependencies": {
    "@babel/cli": "^7.19.3",
    "@babel/core": "^7.20.2",
    "@babel/node": "^7.20.2",
    "@babel/preset-env": "^7.20.2",
    "nodemon": "^2.0.20"
  }
}
EOF

# Babel config
cat > .babelrc << 'EOF'
{
  "presets": ["@babel/preset-env"]
}
EOF

# Source directory
mkdir src
cat > src/server.js << 'EOF'
import express from 'express';
import compression from 'compression';
import helmet from 'helmet';

const app = express();
const port = process.env.PORT || 3000;

// Security and performance middleware
app.use(helmet());
app.use(compression());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: '🚀 Optimized Docker Application',
    features: [
      'Multi-stage build',
      'Layer optimization',
      'Security hardening',
      'Minimal production image',
      'Non-root user'
    ],
    environment: process.env.NODE_ENV,
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Optimized server running on port ${port}`);
});
EOF
```

### Step 3: Create Optimized Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Multi-stage build for maximum optimization
ARG NODE_VERSION=16
ARG APP_VERSION=1.0.0

# Stage 1: Build stage
FROM node:${NODE_VERSION}-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy package files for better caching
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm ci --only=production --silent && \
    npm ci --silent

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production stage
FROM node:${NODE_VERSION}-alpine AS production

# Set build-time variables
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Install only production dependencies
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production --silent && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
CMD ["node", "dist/server.js"]
EOF
```

### Step 4: Create .dockerignore

```bash
cat > .dockerignore << 'EOF'
# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist
build
.next

# Environment files
.env
.env.local
.env.*.local

# Version control
.git
.gitignore

# IDE
.vscode
.idea
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Documentation
README.md
docs/
*.md

# Docker
Dockerfile*
docker-compose*
.dockerignore

# Logs
logs
*.log

# Coverage
coverage
.nyc_output
EOF
```

### Step 5: Build and Test

```bash
# Build the optimized image
docker build -t optimized-app .

# Check the image size
docker images optimized-app

# Run with health checks
docker run -d -p 3000:3000 --name optimized-app optimized-app

# Test the application
curl http://localhost:3000
curl http://localhost:3000/health

# Check health status
docker ps
```

## 🎯 Best Practices Summary

### 1. Multi-Stage Builds
- Use for separating build and runtime environments
- Keep final images minimal
- Copy only necessary artifacts

### 2. Build Arguments
- Make Dockerfiles flexible and reusable
- Provide sensible defaults
- Document all arguments

### 3. Layer Optimization
- Order instructions by change frequency
- Combine related RUN commands
- Use .dockerignore effectively

### 4. Security
- Run as non-root user
- Use official base images
- Keep images updated

### 5. Performance
- Minimize image size
- Use alpine variants when possible
- Implement health checks

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Create multi-stage Dockerfiles
- [ ] Use build arguments effectively
- [ ] Optimize Docker layers
- [ ] Set proper file permissions
- [ ] Create minimal production images

## 🚀 What's Next?

Fantastic! You've mastered advanced Dockerfile techniques. In the next lesson, we'll explore [Working with Red Hat Universal Base Images](03-red-hat-ubi.md) where you'll learn about enterprise-grade base images for production environments.

## 📝 Quick Reference Card

```dockerfile
# Multi-stage build
FROM node:16 AS builder
# ... build steps ...

FROM node:16-alpine AS production
COPY --from=builder /app/dist ./dist

# Build arguments
ARG NODE_VERSION=16
FROM node:${NODE_VERSION}-alpine

# Advanced COPY
COPY --chown=user:group --from=stage /src /dest

# Layer optimization
RUN command1 && \
    command2 && \
    cleanup
```

```bash
# Build with arguments
docker build --build-arg NODE_VERSION=18 -t app .

# Multi-stage build targeting specific stage
docker build --target builder -t app:builder .
```

---

*"Optimization is not about doing more things faster. It's about doing the right things efficiently."* - You're now building Docker images like a pro! 🚀
