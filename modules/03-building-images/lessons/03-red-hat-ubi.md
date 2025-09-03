# 🔴 Lesson 3: Red Hat Universal Base Images - Enterprise-Grade Foundations

*"Building on rock-solid, enterprise-ready foundations"*

Welcome to the enterprise world of container images! While you've been using community images like `ubuntu` and `alpine`, there's a whole category of enterprise-grade base images designed for production environments. Red Hat Universal Base Images (UBI) are free, redistributable, and built for serious business.

## 🎯 What You'll Learn

- What Red Hat Universal Base Images (UBI) are and why they matter
- Security and compliance benefits of UBI
- How to build production-ready images with UBI
- Enterprise considerations for container deployments
- Migration strategies from community to enterprise images

## 🏢 What are Red Hat Universal Base Images?

Think of UBI as the "enterprise edition" of base images. While community images are like open-source software, UBI images are like enterprise software - they come with:

- **Security**: Regular security updates and vulnerability scanning
- **Support**: Backed by Red Hat's enterprise support
- **Compliance**: Built to meet enterprise compliance requirements
- **Stability**: Long-term support and predictable update cycles
- **Legal clarity**: Clear licensing and redistribution rights

### UBI vs Community Images

```
Community Images (ubuntu, alpine, debian):
├── 🆓 Free to use
├── 🌍 Community maintained
├── ⚡ Fast updates
├── 🔄 Frequent changes
└── ❓ Variable support

Red Hat UBI:
├── 🆓 Free to use and redistribute
├── 🏢 Enterprise maintained
├── 🛡️ Security focused
├── 📋 Compliance ready
└── 🎯 Production optimized
```

## 🔍 Available UBI Images

Red Hat provides several UBI variants for different use cases:

### Base UBI Images

```dockerfile
# Minimal UBI (like alpine)
FROM registry.access.redhat.com/ubi8/ubi-minimal

# Standard UBI (like ubuntu)
FROM registry.access.redhat.com/ubi8/ubi

# UBI with development tools
FROM registry.access.redhat.com/ubi8/ubi-init
```

### Language-Specific UBI Images

```dockerfile
# Node.js on UBI
FROM registry.access.redhat.com/ubi8/nodejs-16

# Python on UBI
FROM registry.access.redhat.com/ubi8/python-39

# Java on UBI
FROM registry.access.redhat.com/ubi8/openjdk-11
```

### Application UBI Images

```dockerfile
# nginx on UBI
FROM registry.access.redhat.com/ubi8/nginx-120

# Apache httpd on UBI
FROM registry.access.redhat.com/ubi8/httpd-24
```

## 🧪 Lab 1: Your First UBI Application

Let's build a Node.js application using Red Hat UBI!

### Step 1: Create UBI Project

```bash
mkdir ubi-node-app
cd ubi-node-app
```

### Step 2: Create package.json

```bash
cat > package.json << 'EOF'
{
  "name": "ubi-node-app",
  "version": "1.0.0",
  "description": "Node.js application built on Red Hat UBI",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
```

### Step 3: Create server.js

```bash
cat > server.js << 'EOF'
const express = require('express');
const os = require('os');
const fs = require('fs');

const app = express();
const port = process.env.PORT || 8080;

// Read OS release information
let osInfo = 'Unknown';
try {
  osInfo = fs.readFileSync('/etc/os-release', 'utf8');
} catch (err) {
  console.log('Could not read OS info');
}

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Red Hat UBI Application</title>
        <style>
          body { 
            font-family: 'Red Hat Display', Arial, sans-serif; 
            background: linear-gradient(135deg, #ee0000 0%, #cc0000 100%);
            color: white;
            margin: 0;
            padding: 40px;
          }
          .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
          }
          .logo {
            font-size: 3em;
            margin-bottom: 20px;
          }
          .info-box {
            background: rgba(255,255,255,0.2);
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
            border-left: 5px solid #ffffff;
          }
          pre {
            background: rgba(0,0,0,0.3);
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-size: 0.9em;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="logo">🔴 Red Hat UBI</div>
          <h1>Enterprise-Grade Container Application</h1>
          
          <div class="info-box">
            <h3>🏢 Enterprise Benefits</h3>
            <ul>
              <li>✅ Security-focused base image</li>
              <li>✅ Enterprise support available</li>
              <li>✅ Compliance-ready</li>
              <li>✅ Long-term stability</li>
              <li>✅ Free to use and redistribute</li>
            </ul>
          </div>

          <div class="info-box">
            <h3>📊 System Information</h3>
            <p><strong>Container ID:</strong> ${os.hostname()}</p>
            <p><strong>Node.js Version:</strong> ${process.version}</p>
            <p><strong>Platform:</strong> ${os.platform()}</p>
            <p><strong>Architecture:</strong> ${os.arch()}</p>
            <p><strong>Uptime:</strong> ${Math.floor(os.uptime())} seconds</p>
          </div>

          <div class="info-box">
            <h3>🐧 Operating System Details</h3>
            <pre>${osInfo}</pre>
          </div>
        </div>
      </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🔴 Red Hat UBI application running on port ${port}`);
  console.log(`🏢 Enterprise-grade container ready for production!`);
});
EOF
```

### Step 4: Create UBI Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Use Red Hat UBI 8 with Node.js
FROM registry.access.redhat.com/ubi8/nodejs-16

# Set metadata labels (enterprise best practice)
LABEL name="ubi-node-app" \
      vendor="Your Company" \
      version="1.0.0" \
      release="1" \
      summary="Node.js application on Red Hat UBI" \
      description="Enterprise-grade Node.js application built on Red Hat Universal Base Image"

# Create application directory
WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy application code
COPY . .

# Create non-root user (security best practice)
USER 1001

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["npm", "start"]
EOF
```

### Step 5: Build and Run

```bash
# Build the UBI-based image
docker build -t ubi-node-app .

# Run the container
docker run -d -p 8080:8080 --name ubi-app ubi-node-app

# Test the application
curl http://localhost:8080/health
```

Visit `http://localhost:8080` to see your enterprise-grade application!

## 🧪 Lab 2: Multi-Stage UBI Build

Let's create a more complex application using UBI with multi-stage builds:

### Step 1: Create Advanced UBI Project

```bash
mkdir advanced-ubi-app
cd advanced-ubi-app
```

### Step 2: Create Application Files

```bash
# package.json with build process
cat > package.json << 'EOF'
{
  "name": "advanced-ubi-app",
  "version": "2.0.0",
  "description": "Advanced UBI application with build process",
  "main": "dist/server.js",
  "scripts": {
    "build": "babel src --out-dir dist --copy-files",
    "start": "node dist/server.js",
    "dev": "nodemon --exec babel-node src/server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "helmet": "^6.0.0",
    "compression": "^1.7.4"
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

# Babel configuration
cat > .babelrc << 'EOF'
{
  "presets": ["@babel/preset-env"]
}
EOF

# Source directory
mkdir src
cat > src/server.js << 'EOF'
import express from 'express';
import helmet from 'helmet';
import compression from 'compression';
import { readFileSync } from 'fs';

const app = express();
const port = process.env.PORT || 8080;

// Security and performance middleware
app.use(helmet());
app.use(compression());
app.use(express.json());

// Read system information
const getSystemInfo = () => {
  try {
    const osRelease = readFileSync('/etc/os-release', 'utf8');
    const redhatRelease = readFileSync('/etc/redhat-release', 'utf8').trim();
    return { osRelease, redhatRelease };
  } catch (err) {
    return { osRelease: 'Not available', redhatRelease: 'Not available' };
  }
};

app.get('/', (req, res) => {
  const systemInfo = getSystemInfo();
  
  res.json({
    message: '🔴 Advanced Red Hat UBI Application',
    version: '2.0.0',
    features: [
      'Multi-stage UBI build',
      'Security hardening with Helmet',
      'Performance optimization',
      'Enterprise compliance',
      'Production-ready architecture'
    ],
    system: {
      nodeVersion: process.version,
      platform: process.platform,
      architecture: process.arch,
      redhatRelease: systemInfo.redhatRelease
    },
    security: {
      helmet: 'enabled',
      compression: 'enabled',
      nonRootUser: process.getuid() !== 0
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    checks: {
      server: 'running',
      memory: process.memoryUsage(),
      uptime: process.uptime()
    }
  });
});

app.get('/system', (req, res) => {
  const systemInfo = getSystemInfo();
  res.json({
    osRelease: systemInfo.osRelease,
    redhatRelease: systemInfo.redhatRelease,
    environment: process.env
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🔴 Advanced UBI application running on port ${port}`);
  console.log(`🏢 Enterprise-grade security and performance enabled`);
});
EOF
```

### Step 3: Create Multi-Stage UBI Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Multi-stage build using Red Hat UBI

# Stage 1: Build stage
FROM registry.access.redhat.com/ubi8/nodejs-16 AS builder

# Set metadata
LABEL stage="builder"

# Install build dependencies
USER root
RUN dnf install -y python3 make gcc-c++ && \
    dnf clean all

# Switch back to default user
USER 1001

WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production stage
FROM registry.access.redhat.com/ubi8/nodejs-16-minimal AS production

# Set comprehensive metadata (enterprise requirement)
LABEL name="advanced-ubi-app" \
      vendor="Your Enterprise" \
      version="2.0.0" \
      release="1" \
      summary="Advanced Node.js application on Red Hat UBI" \
      description="Production-ready Node.js application with security hardening, built on Red Hat Universal Base Image" \
      maintainer="your-team@company.com" \
      url="https://your-company.com" \
      io.k8s.description="Advanced UBI-based Node.js application" \
      io.k8s.display-name="Advanced UBI App" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="nodejs,ubi,enterprise"

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080 \
    NPM_CONFIG_LOGLEVEL=warn

WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built application from builder stage
COPY --from=builder /opt/app-root/src/dist ./dist

# Ensure proper ownership
USER root
RUN chown -R 1001:0 /opt/app-root/src && \
    chmod -R g=u /opt/app-root/src

# Switch to non-root user
USER 1001

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["npm", "start"]
EOF
```

### Step 4: Create .dockerignore

```bash
cat > .dockerignore << 'EOF'
# Dependencies
node_modules
npm-debug.log*

# Build outputs
dist

# Environment files
.env*

# Version control
.git
.gitignore

# IDE
.vscode
.idea

# OS
.DS_Store
Thumbs.db

# Documentation
README.md
docs/

# Docker
Dockerfile*
docker-compose*
.dockerignore

# Logs
logs
*.log
EOF
```

### Step 5: Build and Test

```bash
# Build the advanced UBI image
docker build -t advanced-ubi-app .

# Run the container
docker run -d -p 8080:8080 --name advanced-ubi-app advanced-ubi-app

# Test different endpoints
curl http://localhost:8080
curl http://localhost:8080/health
curl http://localhost:8080/system
```

## 🔒 Security Benefits of UBI

### 1. Regular Security Updates

UBI images receive regular security updates from Red Hat:

```bash
# Check for security updates
docker run --rm registry.access.redhat.com/ubi8/ubi-minimal \
  microdnf update --security

# View security advisories
docker run --rm registry.access.redhat.com/ubi8/ubi \
  dnf updateinfo list security
```

### 2. Vulnerability Scanning

UBI images are regularly scanned for vulnerabilities:

```dockerfile
# Use specific UBI version for reproducible builds
FROM registry.access.redhat.com/ubi8/nodejs-16:1-75

# Check image vulnerabilities (if you have access to Red Hat tools)
# podman image trust show registry.access.redhat.com/ubi8/nodejs-16
```

### 3. Minimal Attack Surface

UBI-minimal provides the smallest possible attack surface:

```dockerfile
# Minimal UBI - smallest footprint
FROM registry.access.redhat.com/ubi8/ubi-minimal

# Install only what you need
RUN microdnf install -y nodejs npm && \
    microdnf clean all
```

## 📋 Enterprise Compliance Features

### 1. Proper Labeling

Enterprise environments require comprehensive metadata:

```dockerfile
LABEL name="myapp" \
      vendor="ACME Corp" \
      version="1.0.0" \
      release="1" \
      summary="Production application" \
      description="Enterprise application built on Red Hat UBI" \
      maintainer="devops@acme.com" \
      url="https://acme.com" \
      vcs-url="https://github.com/acme/myapp" \
      vcs-ref="abc123" \
      build-date="2023-01-01T00:00:00Z" \
      io.k8s.description="Production-ready application" \
      io.k8s.display-name="ACME Application" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="nodejs,production,enterprise"
```

### 2. License Information

```dockerfile
# Copy license files (compliance requirement)
COPY LICENSE /licenses/
COPY NOTICE /licenses/

# Set license label
LABEL license="MIT"
```

### 3. Non-Root User

```dockerfile
# Always run as non-root user
USER 1001

# Or create specific user
RUN useradd -r -u 1001 -g root appuser
USER appuser
```

## 🧪 Lab 3: Enterprise-Ready UBI Application

Let's create a fully enterprise-compliant application:

### Step 1: Create Enterprise Project

```bash
mkdir enterprise-ubi-app
cd enterprise-ubi-app
```

### Step 2: Create License Files

```bash
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2023 Your Enterprise

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

cat > NOTICE << 'EOF'
Enterprise UBI Application
Copyright 2023 Your Enterprise

This product includes software developed by:
- Red Hat, Inc. (https://www.redhat.com/)
- Node.js Foundation (https://nodejs.org/)
- Express.js (https://expressjs.com/)
EOF
```

### Step 3: Create Enterprise Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Enterprise-compliant Red Hat UBI application
FROM registry.access.redhat.com/ubi8/nodejs-16-minimal

# Comprehensive enterprise metadata
LABEL name="enterprise-ubi-app" \
      vendor="Your Enterprise Inc." \
      version="1.0.0" \
      release="1" \
      summary="Enterprise-grade Node.js application on Red Hat UBI" \
      description="Production-ready, security-hardened Node.js application built on Red Hat Universal Base Image with full enterprise compliance" \
      maintainer="DevOps Team <devops@enterprise.com>" \
      url="https://enterprise.com/products/ubi-app" \
      vcs-url="https://github.com/enterprise/ubi-app" \
      vcs-ref="${VCS_REF:-unknown}" \
      build-date="${BUILD_DATE:-unknown}" \
      license="MIT" \
      io.k8s.description="Enterprise Node.js application with security hardening" \
      io.k8s.display-name="Enterprise UBI App" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="nodejs,ubi,enterprise,production" \
      io.openshift.min-memory="128Mi" \
      io.openshift.min-cpu="100m"

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080 \
    NPM_CONFIG_LOGLEVEL=warn \
    APP_NAME="Enterprise UBI App" \
    APP_VERSION="1.0.0"

# Copy license files (compliance requirement)
COPY LICENSE NOTICE /licenses/

# Create application directory with proper permissions
WORKDIR /opt/app-root/src

# Copy package files
COPY package*.json ./

# Install dependencies with security considerations
RUN npm ci --only=production --no-optional && \
    npm cache clean --force && \
    npm audit --audit-level=high

# Copy application code
COPY . .

# Ensure proper ownership and permissions
USER root
RUN chown -R 1001:0 /opt/app-root/src && \
    chmod -R g=u /opt/app-root/src && \
    chmod -R g=u /licenses

# Switch to non-root user (security requirement)
USER 1001

# Expose port
EXPOSE 8080

# Health check with proper timeout
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["npm", "start"]
EOF
```

### Step 4: Create package.json

```bash
cat > package.json << 'EOF'
{
  "name": "enterprise-ubi-app",
  "version": "1.0.0",
  "description": "Enterprise-grade application on Red Hat UBI",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "express": "^4.18.0",
    "helmet": "^6.0.0",
    "compression": "^1.7.4"
  },
  "keywords": ["enterprise", "ubi", "nodejs", "production"],
  "author": "Your Enterprise DevOps Team",
  "license": "MIT"
}
EOF
```

### Step 5: Create Enterprise Application

```bash
cat > server.js << 'EOF'
const express = require('express');
const helmet = require('helmet');
const compression = require('compression');

const app = express();
const port = process.env.PORT || 8080;

// Enterprise security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));

app.use(compression());
app.use(express.json({ limit: '10mb' }));

// Enterprise application routes
app.get('/', (req, res) => {
  res.json({
    application: process.env.APP_NAME,
    version: process.env.APP_VERSION,
    status: 'running',
    environment: process.env.NODE_ENV,
    compliance: {
      security: 'helmet enabled',
      performance: 'compression enabled',
      user: 'non-root',
      licensing: 'MIT licensed',
      support: 'Red Hat UBI base'
    },
    enterprise_features: [
      'Security hardening',
      'Performance optimization',
      'Compliance ready',
      'Enterprise support',
      'Vulnerability scanning',
      'Long-term stability'
    ],
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.APP_VERSION
  });
});

app.get('/compliance', (req, res) => {
  res.json({
    base_image: 'Red Hat UBI 8',
    security_updates: 'Regular Red Hat security updates',
    vulnerability_scanning: 'Red Hat security scanning',
    licensing: 'MIT License',
    support: 'Enterprise support available',
    compliance_standards: [
      'SOC 2',
      'ISO 27001',
      'NIST Cybersecurity Framework',
      'GDPR Ready'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🔴 ${process.env.APP_NAME} running on port ${port}`);
  console.log(`🏢 Enterprise-grade security and compliance enabled`);
  console.log(`🛡️ Running on Red Hat Universal Base Image`);
});
EOF
```

### Step 6: Build and Test Enterprise Application

```bash
# Build with build arguments for metadata
docker build \
  --build-arg VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo "unknown") \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  -t enterprise-ubi-app .

# Run the enterprise application
docker run -d -p 8080:8080 --name enterprise-app enterprise-ubi-app

# Test enterprise endpoints
curl http://localhost:8080
curl http://localhost:8080/health
curl http://localhost:8080/compliance

# Inspect the image metadata
docker inspect enterprise-ubi-app | grep -A 20 "Labels"
```

## 🎯 Best Practices for UBI

### 1. Use Specific Tags

```dockerfile
# Good: Specific version
FROM registry.access.redhat.com/ubi8/nodejs-16:1-75

# Avoid: Latest tag
FROM registry.access.redhat.com/ubi8/nodejs-16:latest
```

### 2. Minimize Package Installation

```dockerfile
# Install only necessary packages
RUN microdnf install -y curl && \
    microdnf clean all
```

### 3. Follow Red Hat Guidelines

```dockerfile
# Use recommended user ID
USER 1001

# Set proper labels
LABEL summary="Brief description" \
      description="Detailed description"

# Copy licenses
COPY LICENSE /licenses/
```

### 4. Regular Updates

```bash
# Regularly rebuild with updated base images
docker build --no-cache -t myapp:$(date +%Y%m%d) .
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Understand the benefits of Red Hat UBI over community images
- [ ] Build applications using UBI base images
- [ ] Implement proper enterprise labeling and metadata
- [ ] Create multi-stage builds with UBI
- [ ] Follow enterprise security best practices

## 🚀 What's Next?

Excellent! You've learned to build enterprise-grade images with Red Hat UBI. In the next lesson, we'll focus on [Image Optimization and Best Practices](04-optimization-best-practices.md) where you'll learn to make your images as efficient and secure as possible.

## 📝 Quick Reference Card

```dockerfile
# UBI Base Images
FROM registry.access.redhat.com/ubi8/ubi-minimal
FROM registry.access.redhat.com/ubi8/nodejs-16
FROM registry.access.redhat.com/ubi8/python-39

# Enterprise Labels
LABEL name="app-name" \
      vendor="Company" \
      version="1.0.0" \
      summary="Brief description" \
      description="Detailed description"

# Security Best Practices
USER 1001
COPY LICENSE /licenses/
RUN microdnf install -y package && microdnf clean all
```

---

*"Enterprise readiness isn't just about features - it's about trust, security, and long-term reliability."* - You're now building enterprise-grade containers! 🏢
