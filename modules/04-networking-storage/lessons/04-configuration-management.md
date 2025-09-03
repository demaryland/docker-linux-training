# ⚙️ Lesson 4: Configuration Management - Configuring Containers for Every Environment

*"One application, many environments - mastering the art of configuration"*

Welcome to configuration management! You've learned to persist data, now let's master the art of configuring applications for different environments. In this lesson, we'll explore environment variables, secrets management, configuration files, and strategies for deploying the same application across development, staging, and production.

## 🎯 What You'll Learn

- Environment variables and their role in container configuration
- Managing secrets securely in containerized applications
- Configuration file strategies and templating
- Multi-environment deployment patterns
- Configuration validation and best practices
- Debugging configuration issues

## 🌍 The Multi-Environment Challenge

Imagine your application as a chameleon:
- **Development**: Bright colors, debug mode, local databases
- **Staging**: Production-like colors, testing mode, staging databases
- **Production**: Professional colors, optimized mode, production databases

### Configuration Without Containers vs With Containers

```
Traditional Deployment:
├── Dev Server (config files, environment setup)
├── Staging Server (different config files, different setup)
└── Production Server (production config files, production setup)

Container Deployment:
├── Same Image
├── Different Environment Variables
└── Different Configuration Sources
```

## 🔧 Environment Variables: The Foundation

Environment variables are the primary way to configure containerized applications.

### Basic Environment Variable Usage

```bash
# Set environment variables at runtime
docker run -e NODE_ENV=production myapp
docker run -e DATABASE_URL=postgresql://localhost/mydb myapp

# Multiple environment variables
docker run \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DATABASE_URL=postgresql://localhost/mydb \
  myapp

# Using environment files
docker run --env-file .env myapp
```

### Environment Variable Hierarchy

```
Priority (highest to lowest):
1. Command line (-e flag)
2. Environment file (--env-file)
3. Dockerfile ENV instructions
4. Base image environment
```

## 🧪 Lab 1: Building a Configurable Application

Let's create an application that adapts to different environments!

### Step 1: Create Configurable Web Application

```bash
mkdir configurable-app
cd configurable-app

# Create a highly configurable application
cat > app.js << 'EOF'
const express = require('express');
const app = express();

// Configuration from environment variables with defaults
const config = {
  port: process.env.PORT || 3000,
  environment: process.env.NODE_ENV || 'development',
  appName: process.env.APP_NAME || 'Configurable App',
  version: process.env.APP_VERSION || '1.0.0',
  
  // Database configuration
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    name: process.env.DB_NAME || 'myapp',
    user: process.env.DB_USER || 'user',
    password: process.env.DB_PASSWORD || 'password'
  },
  
  // Feature flags
  features: {
    debugMode: process.env.DEBUG_MODE === 'true',
    analytics: process.env.ENABLE_ANALYTICS === 'true',
    caching: process.env.ENABLE_CACHING !== 'false', // default true
    rateLimit: parseInt(process.env.RATE_LIMIT) || 100
  },
  
  // External services
  services: {
    redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
    apiKey: process.env.API_KEY || 'default-key',
    webhookUrl: process.env.WEBHOOK_URL || null
  }
};

// Validate required configuration
const requiredEnvVars = ['DB_PASSWORD'];
const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0 && config.environment === 'production') {
  console.error('❌ Missing required environment variables:', missingVars);
  process.exit(1);
}

app.use(express.json());

// Configuration endpoint
app.get('/config', (req, res) => {
  // Don't expose sensitive information
  const safeConfig = {
    ...config,
    database: {
      ...config.database,
      password: '***HIDDEN***'
    },
    services: {
      ...config.services,
      apiKey: config.services.apiKey.substring(0, 4) + '***'
    }
  };
  
  res.json({
    message: 'Application Configuration',
    config: safeConfig,
    timestamp: new Date().toISOString()
  });
});

// Health check with environment info
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    environment: config.environment,
    version: config.version,
    uptime: process.uptime(),
    features: config.features
  });
});

// Environment-specific behavior
app.get('/', (req, res) => {
  const environmentStyles = {
    development: {
      background: 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
      color: '#333',
      badge: '🔧 DEV'
    },
    staging: {
      background: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
      color: '#333',
      badge: '🧪 STAGING'
    },
    production: {
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      color: 'white',
      badge: '🚀 PRODUCTION'
    }
  };
  
  const style = environmentStyles[config.environment] || environmentStyles.development;
  
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>${config.appName} - ${config.environment}</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 0;
            padding: 50px;
            background: ${style.background};
            color: ${style.color};
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .badge {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .config-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .config-card {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
        }
        .feature {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
        }
        .enabled { color: #4CAF50; }
        .disabled { color: #f44336; }
        button {
            background: rgba(255,255,255,0.2);
            color: inherit;
            border: 2px solid rgba(255,255,255,0.3);
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover { background: rgba(255,255,255,0.3); }
    </style>
</head>
<body>
    <div class="container">
        <div class="badge">${style.badge}</div>
        <h1>${config.appName}</h1>
        <p>Version: ${config.version} | Environment: ${config.environment}</p>
        
        <div class="config-grid">
            <div class="config-card">
                <h3>🗄️ Database</h3>
                <p><strong>Host:</strong> ${config.database.host}:${config.database.port}</p>
                <p><strong>Database:</strong> ${config.database.name}</p>
                <p><strong>User:</strong> ${config.database.user}</p>
            </div>
            
            <div class="config-card">
                <h3>🚀 Features</h3>
                <div class="feature">
                    <span>Debug Mode:</span>
                    <span class="${config.features.debugMode ? 'enabled' : 'disabled'}">
                        ${config.features.debugMode ? '✅ ON' : '❌ OFF'}
                    </span>
                </div>
                <div class="feature">
                    <span>Analytics:</span>
                    <span class="${config.features.analytics ? 'enabled' : 'disabled'}">
                        ${config.features.analytics ? '✅ ON' : '❌ OFF'}
                    </span>
                </div>
                <div class="feature">
                    <span>Caching:</span>
                    <span class="${config.features.caching ? 'enabled' : 'disabled'}">
                        ${config.features.caching ? '✅ ON' : '❌ OFF'}
                    </span>
                </div>
                <div class="feature">
                    <span>Rate Limit:</span>
                    <span>${config.features.rateLimit}/min</span>
                </div>
            </div>
            
            <div class="config-card">
                <h3>🔗 Services</h3>
                <p><strong>Redis:</strong> ${config.services.redisUrl}</p>
                <p><strong>API Key:</strong> ${config.services.apiKey.substring(0, 8)}...</p>
                <p><strong>Webhook:</strong> ${config.services.webhookUrl || 'Not configured'}</p>
            </div>
        </div>
        
        <button onclick="fetch('/config').then(r=>r.json()).then(d=>alert(JSON.stringify(d,null,2)))">
            View Full Config
        </button>
        <button onclick="fetch('/health').then(r=>r.json()).then(d=>alert(JSON.stringify(d,null,2)))">
            Health Check
        </button>
    </div>
</body>
</html>
  `);
});

// Simulate different behavior based on environment
app.get('/api/data', (req, res) => {
  const data = {
    message: 'API Response',
    environment: config.environment,
    timestamp: new Date().toISOString()
  };
  
  // Add debug information in development
  if (config.features.debugMode) {
    data.debug = {
      requestHeaders: req.headers,
      processId: process.pid,
      memoryUsage: process.memoryUsage()
    };
  }
  
  // Simulate different response times
  const delay = config.environment === 'development' ? 0 : 
                config.environment === 'staging' ? 100 : 50;
  
  setTimeout(() => {
    res.json(data);
  }, delay);
});

app.listen(config.port, '0.0.0.0', () => {
  console.log(`🚀 ${config.appName} v${config.version} running on port ${config.port}`);
  console.log(`🌍 Environment: ${config.environment}`);
  console.log(`🔧 Debug mode: ${config.features.debugMode ? 'ON' : 'OFF'}`);
  
  if (config.environment === 'development') {
    console.log('📋 Available endpoints:');
    console.log('  GET  /         - Main application');
    console.log('  GET  /config   - Configuration view');
    console.log('  GET  /health   - Health check');
    console.log('  GET  /api/data - API endpoint');
  }
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "configurable-app",
  "version": "1.0.0",
  "description": "Highly configurable application for multi-environment deployment",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy application
COPY app.js ./

# Default environment variables (can be overridden)
ENV NODE_ENV=production
ENV PORT=3000
ENV APP_NAME="Configurable App"
ENV APP_VERSION="1.0.0"

EXPOSE 3000

CMD ["npm", "start"]
EOF
```

### Step 2: Create Environment-Specific Configuration Files

```bash
# Development environment
cat > .env.development << 'EOF'
NODE_ENV=development
PORT=3000
APP_NAME=Configurable App (Dev)
APP_VERSION=1.0.0-dev
DEBUG_MODE=true
ENABLE_ANALYTICS=false
ENABLE_CACHING=false
RATE_LIMIT=1000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp_dev
DB_USER=dev_user
DB_PASSWORD=dev_password

# Services
REDIS_URL=redis://localhost:6379/0
API_KEY=dev-api-key-12345
WEBHOOK_URL=http://localhost:8080/webhook
EOF

# Staging environment
cat > .env.staging << 'EOF'
NODE_ENV=staging
PORT=3000
APP_NAME=Configurable App (Staging)
APP_VERSION=1.0.0-staging
DEBUG_MODE=false
ENABLE_ANALYTICS=true
ENABLE_CACHING=true
RATE_LIMIT=500

# Database
DB_HOST=staging-db.company.com
DB_PORT=5432
DB_NAME=myapp_staging
DB_USER=staging_user
DB_PASSWORD=staging_secure_password

# Services
REDIS_URL=redis://staging-redis.company.com:6379/0
API_KEY=staging-api-key-67890
WEBHOOK_URL=https://staging-webhook.company.com/webhook
EOF

# Production environment
cat > .env.production << 'EOF'
NODE_ENV=production
PORT=3000
APP_NAME=Configurable App
APP_VERSION=1.0.0
DEBUG_MODE=false
ENABLE_ANALYTICS=true
ENABLE_CACHING=true
RATE_LIMIT=100

# Database
DB_HOST=prod-db.company.com
DB_PORT=5432
DB_NAME=myapp_production
DB_USER=prod_user
DB_PASSWORD=super_secure_production_password

# Services
REDIS_URL=redis://prod-redis.company.com:6379/0
API_KEY=production-api-key-abcdef
WEBHOOK_URL=https://webhook.company.com/webhook
EOF
```

### Step 3: Build and Test Different Environments

```bash
# Build the application
docker build -t configurable-app .

# Test development environment
echo "🔧 Testing Development Environment"
docker run -d --name app-dev -p 3001:3000 --env-file .env.development configurable-app

# Test staging environment
echo "🧪 Testing Staging Environment"
docker run -d --name app-staging -p 3002:3000 --env-file .env.staging configurable-app

# Test production environment
echo "🚀 Testing Production Environment"
docker run -d --name app-prod -p 3003:3000 --env-file .env.production configurable-app

# Check all containers are running
docker ps | grep configurable-app

# Test each environment
echo "Development: http://localhost:3001"
echo "Staging: http://localhost:3002"
echo "Production: http://localhost:3003"

# Quick health checks
curl -s http://localhost:3001/health | jq .environment
curl -s http://localhost:3002/health | jq .environment
curl -s http://localhost:3003/health | jq .environment
```

## 🔐 Secrets Management

Secrets require special handling to avoid exposure in logs, images, or configuration files.

### Docker Secrets (Swarm Mode)

```bash
# Create secrets in Docker Swarm
echo "super_secret_password" | docker secret create db_password -
echo "api_key_12345" | docker secret create api_key -

# Use secrets in services
docker service create \
  --name myapp \
  --secret db_password \
  --secret api_key \
  myapp:latest
```

### Environment Variable Secrets (Single Host)

```bash
# Read secrets from files
docker run -d \
  -e DB_PASSWORD_FILE=/run/secrets/db_password \
  -v /path/to/secrets:/run/secrets:ro \
  myapp
```

## 🧪 Lab 2: Implementing Secure Configuration

Let's enhance our application with proper secrets management!

### Step 1: Create Secrets-Aware Application

```bash
mkdir secure-config-app
cd secure-config-app

# Create application with secrets support
cat > secure-app.js << 'EOF'
const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();

// Function to read secrets from files or environment
function getSecret(name, defaultValue = null) {
  const fileEnvVar = `${name}_FILE`;
  const secretFile = process.env[fileEnvVar];
  
  if (secretFile && fs.existsSync(secretFile)) {
    try {
      return fs.readFileSync(secretFile, 'utf8').trim();
    } catch (error) {
      console.warn(`Warning: Could not read secret file ${secretFile}`);
    }
  }
  
  return process.env[name] || defaultValue;
}

// Configuration with secrets support
const config = {
  port: process.env.PORT || 3000,
  environment: process.env.NODE_ENV || 'development',
  appName: process.env.APP_NAME || 'Secure App',
  
  // Secrets - these should never be logged
  secrets: {
    dbPassword: getSecret('DB_PASSWORD', 'default_password'),
    apiKey: getSecret('API_KEY', 'default_api_key'),
    jwtSecret: getSecret('JWT_SECRET', 'default_jwt_secret'),
    encryptionKey: getSecret('ENCRYPTION_KEY', 'default_encryption_key')
  },
  
  // Non-sensitive configuration
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    name: process.env.DB_NAME || 'myapp',
    user: process.env.DB_USER || 'user'
  }
};

// Validate secrets in production
if (config.environment === 'production') {
  const requiredSecrets = ['dbPassword', 'apiKey', 'jwtSecret'];
  const missingSecrets = requiredSecrets.filter(secret => 
    !config.secrets[secret] || config.secrets[secret] === `default_${secret.toLowerCase()}`
  );
  
  if (missingSecrets.length > 0) {
    console.error('❌ Missing or default secrets in production:', missingSecrets);
    process.exit(1);
  }
}

app.use(express.json());

// Safe configuration endpoint (no secrets)
app.get('/config', (req, res) => {
  const safeConfig = {
    environment: config.environment,
    appName: config.appName,
    database: config.database,
    secretsConfigured: {
      dbPassword: !!config.secrets.dbPassword && config.secrets.dbPassword !== 'default_password',
      apiKey: !!config.secrets.apiKey && config.secrets.apiKey !== 'default_api_key',
      jwtSecret: !!config.secrets.jwtSecret && config.secrets.jwtSecret !== 'default_jwt_secret',
      encryptionKey: !!config.secrets.encryptionKey && config.secrets.encryptionKey !== 'default_encryption_key'
    }
  };
  
  res.json(safeConfig);
});

// Secrets validation endpoint
app.get('/secrets/validate', (req, res) => {
  const validation = {
    dbPassword: {
      configured: config.secrets.dbPassword !== 'default_password',
      length: config.secrets.dbPassword.length,
      isDefault: config.secrets.dbPassword === 'default_password'
    },
    apiKey: {
      configured: config.secrets.apiKey !== 'default_api_key',
      length: config.secrets.apiKey.length,
      isDefault: config.secrets.apiKey === 'default_api_key'
    },
    jwtSecret: {
      configured: config.secrets.jwtSecret !== 'default_jwt_secret',
      length: config.secrets.jwtSecret.length,
      isDefault: config.secrets.jwtSecret === 'default_jwt_secret'
    }
  };
  
  const allConfigured = Object.values(validation).every(v => v.configured);
  
  res.json({
    status: allConfigured ? 'secure' : 'insecure',
    environment: config.environment,
    validation: validation,
    recommendation: allConfigured ? 
      'All secrets are properly configured' : 
      'Some secrets are using default values - update for security'
  });
});

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>Secure Configuration Demo</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 50px auto; 
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .status-card {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
        }
        .secure { border-left: 5px solid #4CAF50; }
        .insecure { border-left: 5px solid #f44336; }
        button {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 2px solid rgba(255,255,255,0.3);
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover { background: rgba(255,255,255,0.3); }
        pre {
            background: rgba(0,0,0,0.3);
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Secure Configuration Management</h1>
        <p>This application demonstrates secure secrets management in containers.</p>
        
        <div class="status-card">
            <h3>🌍 Environment: ${config.environment}</h3>
            <p>Application: ${config.appName}</p>
        </div>
        
        <button onclick="checkConfig()">View Safe Config</button>
        <button onclick="validateSecrets()">Validate Secrets</button>
        
        <div id="result"></div>
        
        <h3>🔒 Security Features</h3>
        <ul>
            <li>✅ Secrets read from files or environment variables</li>
            <li>✅ No secrets exposed in configuration endpoints</li>
            <li>✅ Production validation for required secrets</li>
            <li>✅ Default value detection and warnings</li>
        </ul>
        
        <script>
            async function checkConfig() {
                try {
                    const response = await fetch('/config');
                    const data = await response.json();
                    document.getElementById('result').innerHTML = 
                        '<h3>📋 Safe Configuration</h3><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                } catch (error) {
                    console.error('Error:', error);
                }
            }
            
            async function validateSecrets() {
                try {
                    const response = await fetch('/secrets/validate');
                    const data = await response.json();
                    const statusClass = data.status === 'secure' ? 'secure' : 'insecure';
                    document.getElementById('result').innerHTML = 
                        '<div class="status-card ' + statusClass + '"><h3>🔐 Secrets Validation</h3><pre>' + 
                        JSON.stringify(data, null, 2) + '</pre></div>';
                } catch (error) {
                    console.error('Error:', error);
                }
            }
        </script>
    </div>
</body>
</html>
  `);
});

app.listen(config.port, '0.0.0.0', () => {
  console.log(`🔐 Secure app running on port ${config.port}`);
  console.log(`🌍 Environment: ${config.environment}`);
  
  // Log configuration status (but never the actual secrets!)
  const secretsStatus = Object.keys(config.secrets).map(key => ({
    [key]: config.secrets[key] !== `default_${key.toLowerCase()}`
  }));
  console.log('🔒 Secrets configured:', secretsStatus);
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "secure-config-app",
  "version": "1.0.0",
  "description": "Application with secure configuration management",
  "main": "secure-app.js",
  "scripts": {
    "start": "node secure-app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY secure-app.js ./

# Create directory for secrets
RUN mkdir -p /run/secrets

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
EOF
```

### Step 2: Create Secrets Files

```bash
# Create secrets directory
mkdir secrets

# Create secret files
echo "super_secure_database_password_123" > secrets/db_password
echo "production_api_key_abcdef123456" > secrets/api_key
echo "jwt_secret_very_long_and_secure_string" > secrets/jwt_secret
echo "encryption_key_32_chars_long_12345" > secrets/encryption_key

# Set proper permissions
chmod 600 secrets/*
```

### Step 3: Test Secure Configuration

```bash
# Build secure app
docker build -t secure-config-app .

# Test with environment variables (insecure - uses defaults)
docker run -d --name secure-app-env -p 3001:3000 secure-config-app

# Test with secrets files (secure)
docker run -d \
  --name secure-app-files \
  -p 3002:3000 \
  -e DB_PASSWORD_FILE=/run/secrets/db_password \
  -e API_KEY_FILE=/run/secrets/api_key \
  -e JWT_SECRET_FILE=/run/secrets/jwt_secret \
  -e ENCRYPTION_KEY_FILE=/run/secrets/encryption_key \
  -v $(pwd)/secrets:/run/secrets:ro \
  secure-config-app

# Test with mixed configuration
docker run -d \
  --name secure-app-mixed \
  -p 3003:3000 \
  -e DB_PASSWORD=env_password_123 \
  -e API_KEY_FILE=/run/secrets/api_key \
  -v $(pwd)/secrets:/run/secrets:ro \
  secure-config-app

# Check secrets validation
echo "Environment variables only:"
curl -s http://localhost:3001/secrets/validate | jq .

echo -e "\nSecrets from files:"
curl -s http://localhost:3002/secrets/validate | jq .

echo -e "\nMixed configuration:"
curl -s http://localhost:3003/secrets/validate | jq .
```

## 📁 Configuration Files and Templates

For complex configurations, files are often better than environment variables.

### Configuration File Strategies

```bash
# Mount configuration files
docker run -d \
  -v $(pwd)/config.yml:/app/config.yml:ro \
  myapp

# Use init containers to generate config
docker run --rm \
  -v config-volume:/config \
  config-generator:latest

docker run -d \
  -v config-volume:/app/config \
  myapp
```

## 🧪 Lab 3: Configuration Templates and File Management

Let's create a system that generates configuration files from templates!

### Step 1: Create Configuration Template System

```bash
mkdir config-template-system
cd config-template-system

# Create configuration template
cat > config.template.yml << 'EOF'
# Application Configuration Template
app:
  name: "${APP_NAME}"
  version: "${APP_VERSION}"
  environment: "${NODE_ENV}"
  port: ${PORT}
  
database:
  host: "${DB_HOST}"
  port: ${DB_PORT}
  name: "${DB_NAME}"
  user: "${DB_USER}"
  password: "${DB_PASSWORD}"
  pool:
    min: ${DB_POOL_MIN:-5}
    max: ${DB_POOL_MAX:-20}
    
redis:
  url: "${REDIS_URL}"
  ttl: ${REDIS_TTL:-3600}
  
features:
  debug: ${DEBUG_MODE:-false}
  analytics: ${ENABLE_ANALYTICS:-false}
  caching: ${ENABLE_CACHING:-true}
  rateLimit: ${RATE_LIMIT:-100}
  
logging:
  level: "${LOG_LEVEL:-info}"
  format: "${LOG_FORMAT:-json}"
  
security:
  cors:
    enabled: ${CORS_ENABLED:-true}
    origins: "${CORS_ORIGINS:-*}"
  helmet:
    enabled: ${HELMET_ENABLED:-true}
EOF

# Create template processor script
cat > process-template.js << 'EOF'
const fs = require('fs');
const path = require('path');

function processTemplate(templatePath, outputPath) {
  console.log(`📝 Processing template: ${templatePath}`);
  
  // Read template
  let template = fs.readFileSync(templatePath, 'utf8');
  
  // Replace environment variables
  template = template.replace(/\$\{([^}]+)\}/g, (match, varName) => {
    // Handle default values: ${VAR:-default}
    const [envVar, defaultValue] = varName.split(':-');
    const value = process.env[envVar] || defaultValue || '';
    
    // Convert string booleans to actual booleans in YAML
    if (value === 'true' || value === 'false') {
      return value;
    }
    
    // Convert string numbers to numbers in YAML
    if (!isNaN(value) && value !== '') {
      return value;
    }
    
    return value;
  });
  
  // Write processed configuration
  fs.writeFileSync(outputPath, template);
  console.log(`✅ Configuration written to: ${outputPath}`);
}

// Main execution
if (require.main === module) {
  const templatePath = process.argv[2] || 'config.template.yml';
  const outputPath = process.argv[3] || 'config.yml';
  
  if (!fs.existsSync(templatePath)) {
    console.error(`❌ Template file not found: ${templatePath}`);
    process.exit(1);
  }
  
  processTemplate(templatePath, outputPath);
}

module.exports = { processTemplate };
EOF

# Create application that uses generated config
cat > config-app.js << 'EOF'
const express = require('express');
const fs = require('fs');
const yaml = require('js-yaml');

const app = express();

// Load configuration from YAML file
let config;
try {
  const configFile = process.env.CONFIG_FILE || '/app/config/config.yml';
  const configContent = fs.readFileSync(configFile, 'utf8');
  config = yaml.load(configContent);
  console.log('📋 Configuration loaded from:', configFile);
} catch (error) {
  console.error('❌ Failed to load configuration:', error.message);
  process.exit(1);
}

app.use(express.json());

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>Configuration Template Demo</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 1000px; 
            margin: 50px auto; 
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        .config-section {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
        }
        pre {
            background: rgba(0,0,0,0.3);
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            white-space: pre-wrap;
        }
        button {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 2px solid rgba(255,255,255,0.3);
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover { background: rgba(255,255,255,0.3); }
    </style>
</head>
<body>
    <div class="container">
        <h1>📁 Configuration Template System</h1>
        <p>This application demonstrates configuration file generation from templates.</p>
        
        <div class="config-section">
            <h3>🏷️ Application Info</h3>
            <p><strong>Name:</strong> ${config.app.name}</p>
            <p><strong>Version:</strong> ${config.app.version}</p>
            <p><strong>Environment:</strong> ${config.app.environment}</p>
            <p><strong>Port:</strong> ${config.app.port}</p>
        </div>
        
        <button onclick="showFullConfig()">Show Full Configuration</button>
        <button onclick="showFeatures()">Show Features</button>
        
        <div id="result"></div>
    </div>
    
    <script>
        function showFullConfig() {
            fetch('/config')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('result').innerHTML = 
                        '<div class="config-section"><h3>📋 Full Configuration</h3><pre>' + 
                        JSON.stringify(data, null, 2) + '</pre></div>';
                });
        }
        
        function showFeatures() {
            fetch('/features')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('result').innerHTML = 
                        '<div class="config-section"><h3>🚀 Feature Flags</h3><pre>' + 
                        JSON.stringify(data, null, 2) + '</pre></div>';
                });
        }
    </script>
</body>
</html>
  `);
});

app.get('/config', (req, res) => {
  // Return safe configuration (hide sensitive data)
  const safeConfig = {
    ...config,
    database: {
      ...config.database,
      password: '***HIDDEN***'
    }
  };
  res.json(safeConfig);
});

app.get('/features', (req, res) => {
  res.json(config.features);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    config_loaded: true,
    environment: config.app.environment,
    version: config.app.version
  });
});

app.listen(config.app.port, '0.0.0.0', () => {
  console.log(`🚀 ${config.app.name} running on port ${config.app.port}`);
  console.log(`🌍 Environment: ${config.app.environment}`);
});
EOF

# Create package.json for config system
cat > package.json << 'EOF'
{
  "name": "config-template-system",
  "version": "1.0.0",
  "description": "Configuration template processing system",
  "main": "config-app.js",
  "scripts": {
    "process-config": "node process-template.js",
    "start": "node config-app.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "js-yaml": "^4.1.0"
  }
}
EOF

# Create Dockerfile with config processing
cat > Dockerfile << 'EOF'
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy template processor and application
COPY process-template.js ./
COPY config-app.js ./

# Create config directory
RUN mkdir -p /app/config

# Copy template
COPY config.template.yml ./

ENV NODE_ENV=production
ENV CONFIG_FILE=/app/config/config.yml

EXPOSE 3000

# Process template and start application
CMD ["sh", "-c", "node process-template.js config.template.yml /app/config/config.yml && npm start"]
EOF
```

### Step 2: Create Environment-Specific Template Variables

```bash
# Development environment variables
cat > .env.template.development << 'EOF'
NODE_ENV=development
APP_NAME=Template Config App (Dev)
APP_VERSION=1.0.0-dev
PORT=3000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=template_app_dev
DB_USER=dev_user
DB_PASSWORD=dev_password
DB_POOL_MIN=2
DB_POOL_MAX=10

# Redis
REDIS_URL=redis://localhost:6379/0
REDIS_TTL=1800

# Features
DEBUG_MODE=true
ENABLE_ANALYTICS=false
ENABLE_CACHING=false
RATE_LIMIT=1000

# Logging
LOG_LEVEL=debug
LOG_FORMAT=pretty

# Security
CORS_ENABLED=true
CORS_ORIGINS=*
HELMET_ENABLED=false
EOF

# Production environment variables
cat > .env.template.production << 'EOF'
NODE_ENV=production
APP_NAME=Template Config App
APP_VERSION=1.0.0
PORT=3000

# Database
DB_HOST=prod-db.company.com
DB_PORT=5432
DB_NAME=template_app_prod
DB_USER=prod_user
DB_PASSWORD=super_secure_prod_password
DB_POOL_MIN=10
DB_POOL_MAX=50

# Redis
REDIS_URL=redis://prod-redis.company.com:6379/0
REDIS_TTL=3600

# Features
DEBUG_MODE=false
ENABLE_ANALYTICS=true
ENABLE_CACHING=true
RATE_LIMIT=100

# Logging
LOG_LEVEL=info
LOG_FORMAT=json

# Security
CORS_ENABLED=true
CORS_ORIGINS=https://myapp.company.com
HELMET_ENABLED=true
EOF
```

### Step 3: Build and Test Template System

```bash
# Build the template system
docker build -t config-template-app .

# Test development configuration
docker run -d \
  --name template-app-dev \
  -p 3001:3000 \
  --env-file .env.template.development \
  config-template-app

# Test production configuration
docker run -d \
  --name template-app-prod \
  -p 3002:3000 \
  --env-file .env.template.production \
  config-template-app

# Check generated configurations
echo "Development config:"
curl -s http://localhost:3001/config | jq .

echo -e "\nProduction config:"
curl -s http://localhost:3002/config | jq .

# Check feature differences
echo -e "\nDevelopment features:"
curl -s http://localhost:3001/features | jq .

echo -e "\nProduction features:"
curl -s http://localhost:3002/features | jq .
```

## 🔍 Configuration Debugging and Validation

### Configuration Validation Strategies

```bash
# Validate configuration before starting
docker run --rm \
  --env-file .env.production \
  config-template-app \
  node -e "
    const config = require('./config.json');
    const required = ['database.host', 'database.password'];
    const missing = required.filter(key => !config[key]);
    if (missing.length) {
      console.error('Missing config:', missing);
      process.exit(1);
    }
    console.log('✅ Configuration valid');
  "
```

### Configuration Debugging Tools

```bash
# Debug configuration loading
docker run -it --rm \
  --env-file .env.development \
  config-template-app \
  sh -c "
    echo '🔍 Environment Variables:';
    env | grep -E '^(NODE_ENV|DB_|APP_)' | sort;
    echo '';
    echo '📋 Processed Configuration:';
    node process-template.js config.template.yml /tmp/debug-config.yml;
    cat /tmp/debug-config.yml;
  "
```

## 🎯 Best Practices for Configuration Management

### 1. Configuration Hierarchy

```
Priority (highest to lowest):
1. Command line arguments
2. Environment variables
3. Configuration files
4. Default values
```

### 2. Environment-Specific Patterns

```bash
# Good: Environment-specific files
.env.development
.env.staging
.env.production

# Good: Environment-specific overrides
config/
├── base.yml
├── development.yml
├── staging.yml
└── production.yml
```

### 3. Security Best Practices

```bash
# ✅ Good: Separate secrets from configuration
-e DB_PASSWORD_FILE=/run/secrets/db_password

# ❌ Avoid: Secrets in environment variables
-e DB_PASSWORD=plaintext_password

# ✅ Good: Validate required configuration
if [ -z "$REQUIRED_VAR" ]; then exit 1; fi

# ✅ Good: Use configuration validation
npm run validate-config
```

### 4. Documentation and Defaults

```bash
# Document all configuration options
cat > CONFIG.md << 'EOF'
# Configuration Options

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| NODE_ENV | development | Application environment |
| PORT | 3000 | Server port |
| DB_HOST | localhost | Database host |
| DB_PASSWORD | - | Database password (required) |
EOF
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Configure applications using environment variables
- [ ] Manage secrets securely in containers
- [ ] Create configuration templates for multiple environments
- [ ] Validate configuration before application startup
- [ ] Debug configuration issues effectively

## 🚀 What's Next?

Excellent! You've mastered configuration management for containerized applications. In the final lesson of this module, we'll explore [Troubleshooting Networks and Storage](05-troubleshooting.md) where you'll learn to diagnose and fix common issues with container networking and storage.

## 📝 Quick Reference Card

```bash
# Environment Variables
docker run -e VAR=value image                 # Single variable
docker run --env-file .env image              # Environment file
docker run -e VAR1=val1 -e VAR2=val2 image   # Multiple variables

# Secrets Management
docker run -e SECRET_FILE=/run/secrets/secret -v secrets:/run/secrets:ro image

# Configuration Files
docker run -v $(pwd)/config.yml:/app/config.yml:ro image

# Template Processing
envsubst < template.yml > config.yml          # Simple substitution
node process-template.js template.yml config.yml  # Advanced processing

# Configuration Validation
docker run --rm image validate-config         # Pre-startup validation
```

---

*"Configuration is the bridge between your code and the environment it runs in - build that bridge strong and flexible!"* - Your applications are now ready for any environment! ⚙️

</content>
<task_progress>
- [x] Create Module 3 lessons (5/5 lessons complete)
- [ ] Create Module 4 lessons (4/5 lessons complete)  
- [ ] Create Module 5 lessons (5 lessons)
- [ ] Create Module 6 lessons (5 lessons)
- [ ] Review and ensure consistency across all modules
</task_progress>
