# 💾 Lesson 3: Data Persistence with Volumes - Making Data Survive

*"From ephemeral to eternal - keeping your data safe and sound"*

Welcome to the world of persistent data! You've learned to connect containers, now let's make sure your data survives container restarts, updates, and even complete rebuilds. In this lesson, we'll explore Docker volumes, bind mounts, and storage strategies that keep your data safe.

## 🎯 What You'll Learn

- Understanding container data lifecycle and the ephemeral problem
- Different types of Docker storage: volumes, bind mounts, and tmpfs
- Creating and managing Docker volumes
- Sharing data between containers
- Backup and restore strategies for persistent data
- Performance considerations for different storage types

## 🔄 The Container Data Problem

Imagine containers as hotel rooms:
- **Without persistence**: Everything you leave behind disappears when you check out
- **With persistence**: You have a safe deposit box that survives between stays
- **Shared persistence**: Multiple guests can access the same storage locker

### Container Lifecycle vs Data Lifecycle

```
Container Lifecycle:
Create → Start → Stop → Remove
  ↓       ↓       ↓       ↓
Data:   Created → Exists → Exists → LOST! 💥

With Volumes:
Create → Start → Stop → Remove
  ↓       ↓       ↓       ↓
Data:   Created → Exists → Exists → SURVIVES! ✅
```

## 📦 Types of Docker Storage

Docker provides three main types of storage, each with different use cases:

### 1. Volumes (Recommended)
*Managed by Docker, stored in Docker's area*

```
Host Machine
├── /var/lib/docker/volumes/
│   ├── myvolume/
│   │   └── _data/
│   │       └── your-files
│   └── database-vol/
│       └── _data/
└── Container mounts: /var/lib/docker/volumes/myvolume/_data
```

### 2. Bind Mounts
*Direct mapping to host filesystem*

```
Host Machine
├── /home/user/project/
│   └── data/
│       └── your-files
└── Container mounts: /home/user/project/data
```

### 3. tmpfs Mounts
*Stored in host memory, not persisted*

```
Host Memory (RAM)
├── tmpfs mount
│   └── temporary-data
└── Container mounts: memory-based storage
```

## 🧪 Lab 1: Understanding Container Data Loss

Let's first experience the data loss problem, then solve it!

### Step 1: Demonstrate Data Loss

```bash
# Create a container and add some data
docker run -it --name data-test ubuntu:20.04 bash

# Inside the container, create some data
echo "Important data that must survive!" > /data/important.txt
mkdir -p /data
echo "User preferences" > /data/config.txt
echo "Application logs" > /data/app.log
ls -la /data/
exit

# Stop and remove the container
docker stop data-test
docker rm data-test

# Try to access the data - it's gone!
docker run -it --name data-test-2 ubuntu:20.04 bash
ls -la /data/  # Empty! Data is lost 💥
exit
docker rm data-test-2
```

### Step 2: Solve with Volumes

```bash
# Create a Docker volume
docker volume create my-persistent-data

# Inspect the volume
docker volume inspect my-persistent-data

# Run container with volume mounted
docker run -it --name data-persistent \
  -v my-persistent-data:/data \
  ubuntu:20.04 bash

# Inside the container, create data
mkdir -p /data
echo "This data will survive!" > /data/important.txt
echo "User preferences" > /data/config.txt
echo "Application logs" > /data/app.log
ls -la /data/
exit

# Remove the container
docker rm data-persistent

# Create a new container with the same volume
docker run -it --name data-persistent-2 \
  -v my-persistent-data:/data \
  ubuntu:20.04 bash

# Check if data survived
ls -la /data/
cat /data/important.txt  # ✅ Data survived!
exit
docker rm data-persistent-2
```

## 🗄️ Volume Management

### Creating and Managing Volumes

```bash
# Create volumes
docker volume create myvolume
docker volume create --driver local myvolume2

# List volumes
docker volume ls

# Inspect volume details
docker volume inspect myvolume

# Remove volumes
docker volume rm myvolume2
docker volume prune  # Remove unused volumes
```

### Volume Naming Strategies

```bash
# Good: Descriptive names
docker volume create webapp-database
docker volume create user-uploads
docker volume create app-config

# Avoid: Generic names
docker volume create vol1
docker volume create data
```

## 🧪 Lab 2: Building a Persistent Web Application

Let's build a complete web application with persistent data!

### Step 1: Create Application with Database

```bash
mkdir persistent-webapp
cd persistent-webapp

# Create a simple blog application
cat > blog-app.js << 'EOF'
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Database setup with persistent storage
const dbPath = '/data/blog.db';
const db = new sqlite3.Database(dbPath);

// Initialize database
db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);
  
  // Add sample data if table is empty
  db.get("SELECT COUNT(*) as count FROM posts", (err, row) => {
    if (row.count === 0) {
      const samplePosts = [
        ['Welcome to Persistent Blog', 'This blog data survives container restarts!'],
        ['Docker Volumes Rock', 'No more data loss when containers are recreated.'],
        ['Persistent Storage', 'Your data is safe with Docker volumes.']
      ];
      
      const stmt = db.prepare("INSERT INTO posts (title, content) VALUES (?, ?)");
      samplePosts.forEach(post => stmt.run(post));
      stmt.finalize();
    }
  });
});

app.use(express.json());
app.use(express.static('public'));

// API endpoints
app.get('/api/posts', (req, res) => {
  db.all("SELECT * FROM posts ORDER BY created_at DESC", (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({
      posts: rows,
      database_location: dbPath,
      storage_type: 'persistent_volume'
    });
  });
});

app.post('/api/posts', (req, res) => {
  const { title, content } = req.body;
  db.run("INSERT INTO posts (title, content) VALUES (?, ?)", [title, content], function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ 
      id: this.lastID,
      message: 'Post created successfully',
      storage: 'Data saved to persistent volume'
    });
  });
});

app.get('/api/stats', (req, res) => {
  db.get("SELECT COUNT(*) as total_posts FROM posts", (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({
      total_posts: row.total_posts,
      database_file: dbPath,
      uptime: process.uptime(),
      container_id: process.env.HOSTNAME
    });
  });
});

// Serve the main page
app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>Persistent Blog</title>
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
        .post {
            background: rgba(255,255,255,0.2);
            padding: 20px;
            margin: 15px 0;
            border-radius: 10px;
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: none;
            border-radius: 5px;
        }
        button {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover { background: #45a049; }
        .stats {
            background: rgba(0,0,0,0.3);
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>💾 Persistent Blog Application</h1>
        <p>This blog demonstrates data persistence with Docker volumes!</p>
        
        <div class="stats" id="stats"></div>
        
        <h2>Create New Post</h2>
        <input type="text" id="title" placeholder="Post title">
        <textarea id="content" rows="4" placeholder="Post content"></textarea>
        <button onclick="createPost()">Create Post</button>
        <button onclick="loadPosts()">Refresh Posts</button>
        <button onclick="loadStats()">Show Stats</button>
        
        <h2>Blog Posts</h2>
        <div id="posts"></div>
        
        <script>
            async function loadPosts() {
                try {
                    const response = await fetch('/api/posts');
                    const data = await response.json();
                    const postsDiv = document.getElementById('posts');
                    
                    postsDiv.innerHTML = data.posts.map(post => \`
                        <div class="post">
                            <h3>\${post.title}</h3>
                            <p>\${post.content}</p>
                            <small>Created: \${new Date(post.created_at).toLocaleString()}</small>
                        </div>
                    \`).join('');
                } catch (error) {
                    console.error('Error loading posts:', error);
                }
            }
            
            async function createPost() {
                const title = document.getElementById('title').value;
                const content = document.getElementById('content').value;
                
                if (!title || !content) {
                    alert('Please fill in both title and content');
                    return;
                }
                
                try {
                    const response = await fetch('/api/posts', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ title, content })
                    });
                    
                    if (response.ok) {
                        document.getElementById('title').value = '';
                        document.getElementById('content').value = '';
                        loadPosts();
                    }
                } catch (error) {
                    console.error('Error creating post:', error);
                }
            }
            
            async function loadStats() {
                try {
                    const response = await fetch('/api/stats');
                    const stats = await response.json();
                    document.getElementById('stats').innerHTML = \`
                        <h3>📊 Application Stats</h3>
                        <p><strong>Total Posts:</strong> \${stats.total_posts}</p>
                        <p><strong>Database File:</strong> \${stats.database_file}</p>
                        <p><strong>Container ID:</strong> \${stats.container_id}</p>
                        <p><strong>Uptime:</strong> \${Math.floor(stats.uptime)} seconds</p>
                    \`;
                } catch (error) {
                    console.error('Error loading stats:', error);
                }
            }
            
            // Load initial data
            loadPosts();
            loadStats();
        </script>
    </div>
</body>
</html>
  `);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`💾 Persistent blog running on port ${port}`);
  console.log(`📁 Database location: ${dbPath}`);
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "persistent-blog",
  "version": "1.0.0",
  "description": "Blog application with persistent storage",
  "main": "blog-app.js",
  "scripts": {
    "start": "node blog-app.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "sqlite3": "^5.1.0"
  }
}
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine

# Install sqlite3 dependencies
RUN apk add --no-cache sqlite python3 make g++

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy application
COPY blog-app.js ./

# Create data directory
RUN mkdir -p /data

EXPOSE 3000

CMD ["npm", "start"]
EOF
```

### Step 2: Create Volumes and Build

```bash
# Create volumes for different types of data
docker volume create blog-database
docker volume create blog-uploads
docker volume create blog-config

# Build the application
docker build -t persistent-blog .

# Inspect our volumes
docker volume ls | grep blog
```

### Step 3: Run Application with Persistent Storage

```bash
# Run the blog application with persistent database
docker run -d \
  --name blog-app \
  -p 3000:3000 \
  -v blog-database:/data \
  persistent-blog

# Check if it's running
docker ps | grep blog-app

# Test the application
curl -s http://localhost:3000/api/stats | jq .
```

### Step 4: Test Data Persistence

```bash
# Open the blog in your browser
echo "Open http://localhost:3000 in your browser"
echo "Create a few blog posts to test persistence"

# Wait for user to create posts, then continue
read -p "Press Enter after creating some blog posts..."

# Stop and remove the container
docker stop blog-app
docker rm blog-app

# Start a new container with the same volume
docker run -d \
  --name blog-app-v2 \
  -p 3000:3000 \
  -v blog-database:/data \
  persistent-blog

# Check if data survived
curl -s http://localhost:3000/api/stats | jq .
echo "Check http://localhost:3000 - your posts should still be there!"
```

## 🔗 Bind Mounts: Direct Host Access

Bind mounts provide direct access to host filesystem, useful for development and configuration.

### When to Use Bind Mounts

```bash
# Development: Live code editing
docker run -d \
  -v $(pwd)/src:/app/src \
  -p 3000:3000 \
  my-dev-app

# Configuration: External config files
docker run -d \
  -v /etc/myapp/config.yml:/app/config.yml:ro \
  my-app

# Logs: Direct access to log files
docker run -d \
  -v /var/log/myapp:/app/logs \
  my-app
```

## 🧪 Lab 3: Development Environment with Bind Mounts

Let's create a development environment where code changes are immediately reflected!

### Step 1: Create Development Application

```bash
mkdir dev-environment
cd dev-environment

# Create a simple web application for development
mkdir src
cat > src/app.js << 'EOF'
const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Serve static files
app.use(express.static('public'));

app.get('/', (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>Development Environment</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 50px auto; 
            padding: 20px;
            background: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .code-info {
            background: #f8f8f8;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            border-left: 4px solid #4CAF50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Development Environment</h1>
        <p>This application demonstrates bind mounts for development!</p>
        
        <div class="code-info">
            <h3>📁 File Information</h3>
            <p><strong>App File:</strong> ${__filename}</p>
            <p><strong>Working Directory:</strong> ${process.cwd()}</p>
            <p><strong>Node Version:</strong> ${process.version}</p>
            <p><strong>Last Modified:</strong> ${new Date().toISOString()}</p>
        </div>
        
        <h2>🚀 Development Features</h2>
        <ul>
            <li>✅ Live code reloading with bind mounts</li>
            <li>✅ Direct file system access</li>
            <li>✅ Instant changes without rebuilding</li>
            <li>✅ Development tools integration</li>
        </ul>
        
        <p><em>Try editing src/app.js on your host machine and refresh this page!</em></p>
    </div>
</body>
</html>
  `);
});

app.get('/api/files', (req, res) => {
  const srcDir = path.join(__dirname);
  fs.readdir(srcDir, (err, files) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    const fileInfo = files.map(file => {
      const filePath = path.join(srcDir, file);
      const stats = fs.statSync(filePath);
      return {
        name: file,
        size: stats.size,
        modified: stats.mtime,
        isDirectory: stats.isDirectory()
      };
    });
    
    res.json({
      directory: srcDir,
      files: fileInfo,
      message: 'Files accessible via bind mount'
    });
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🔧 Development server running on port ${port}`);
  console.log(`📁 Source directory: ${__dirname}`);
});
EOF

# Create package.json for development
cat > package.json << 'EOF'
{
  "name": "dev-environment",
  "version": "1.0.0",
  "description": "Development environment with bind mounts",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js",
    "dev": "nodemon src/app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF

# Create Dockerfile for development
cat > Dockerfile.dev << 'EOF'
FROM node:16-alpine

# Install nodemon globally for development
RUN npm install -g nodemon

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Source code will be mounted via bind mount
# No need to copy source code in development

EXPOSE 3000

# Use nodemon for auto-restart on file changes
CMD ["npm", "run", "dev"]
EOF
```

### Step 2: Build and Run Development Environment

```bash
# Build development image
docker build -f Dockerfile.dev -t dev-app .

# Run with bind mount for live development
docker run -d \
  --name dev-container \
  -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/package.json:/app/package.json \
  dev-app

# Check if it's running
docker logs dev-container
```

### Step 3: Test Live Development

```bash
# Test the application
curl -s http://localhost:3000/api/files | jq .

# Edit the source file to see live changes
echo "Making a change to test live reloading..."
sed -i 's/Development Environment/Live Development Environment/g' src/app.js

# Wait a moment for nodemon to restart
sleep 3

# Check logs to see restart
docker logs --tail 10 dev-container

echo "Check http://localhost:3000 - the title should have changed!"
```

## 💾 Backup and Restore Strategies

### Volume Backup

```bash
# Create a backup of a volume
docker run --rm \
  -v blog-database:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/blog-backup.tar.gz -C /data .

# Verify backup
ls -lh blog-backup.tar.gz
```

### Volume Restore

```bash
# Create new volume for restore
docker volume create blog-database-restored

# Restore from backup
docker run --rm \
  -v blog-database-restored:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/blog-backup.tar.gz -C /data

# Test restored volume
docker run --rm \
  -v blog-database-restored:/data \
  ubuntu ls -la /data
```

## 🧪 Lab 4: Complete Backup and Restore Workflow

Let's implement a complete backup and restore system!

### Step 1: Create Backup Scripts

```bash
mkdir backup-system
cd backup-system

# Create backup script
cat > backup-volumes.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Function to backup a volume
backup_volume() {
    local volume_name=$1
    local backup_name="${volume_name}_${DATE}.tar.gz"
    
    echo "🔄 Backing up volume: $volume_name"
    
    docker run --rm \
        -v $volume_name:/data:ro \
        -v $(pwd):/backup \
        ubuntu tar czf /backup/$backup_name -C /data .
    
    if [ $? -eq 0 ]; then
        echo "✅ Backup completed: $backup_name"
        echo "📁 Size: $(du -h $backup_name | cut -f1)"
    else
        echo "❌ Backup failed for $volume_name"
    fi
}

# Function to list all volumes
list_volumes() {
    echo "📋 Available volumes:"
    docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
}

# Main backup function
main() {
    echo "🚀 Docker Volume Backup System"
    echo "=============================="
    
    if [ "$1" == "list" ]; then
        list_volumes
        exit 0
    fi
    
    if [ -z "$1" ]; then
        echo "Usage: $0 <volume_name> | list"
        echo "Example: $0 blog-database"
        exit 1
    fi
    
    # Check if volume exists
    if ! docker volume inspect $1 >/dev/null 2>&1; then
        echo "❌ Volume '$1' does not exist"
        list_volumes
        exit 1
    fi
    
    backup_volume $1
}

main "$@"
EOF

chmod +x backup-volumes.sh

# Create restore script
cat > restore-volume.sh << 'EOF'
#!/bin/bash

# Function to restore a volume
restore_volume() {
    local backup_file=$1
    local volume_name=$2
    
    if [ ! -f "$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        exit 1
    fi
    
    echo "🔄 Restoring volume: $volume_name from $backup_file"
    
    # Create volume if it doesn't exist
    docker volume create $volume_name >/dev/null 2>&1
    
    # Restore data
    docker run --rm \
        -v $volume_name:/data \
        -v $(pwd):/backup \
        ubuntu tar xzf /backup/$backup_file -C /data
    
    if [ $? -eq 0 ]; then
        echo "✅ Restore completed: $volume_name"
    else
        echo "❌ Restore failed"
    fi
}

# Main restore function
main() {
    echo "🔄 Docker Volume Restore System"
    echo "==============================="
    
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 <backup_file> <volume_name>"
        echo "Example: $0 blog-database_20231201_120000.tar.gz blog-database-restored"
        echo ""
        echo "Available backups:"
        ls -1 *.tar.gz 2>/dev/null || echo "No backup files found"
        exit 1
    fi
    
    restore_volume $1 $2
}

main "$@"
EOF

chmod +x restore-volume.sh
```

### Step 2: Test Backup System

```bash
# List available volumes
./backup-volumes.sh list

# Backup the blog database
./backup-volumes.sh blog-database

# List backup files
ls -lh *.tar.gz

# Test restore to a new volume
./restore-volume.sh blog-database_*.tar.gz blog-database-test

# Verify restored data
docker run --rm \
  -v blog-database-test:/data \
  ubuntu find /data -type f -exec ls -la {} \;
```

### Step 3: Automated Backup with Cron

```bash
# Create automated backup script
cat > automated-backup.sh << 'EOF'
#!/bin/bash

# Configuration
BACKUP_DIR="/home/user/docker-backups"
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

# Backup all volumes
for volume in $(docker volume ls -q); do
    echo "Backing up volume: $volume"
    ./backup-volumes.sh $volume
done

# Clean up old backups
find . -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Automated backup completed at $(date)"
EOF

chmod +x automated-backup.sh

# Add to crontab (example - daily at 2 AM)
echo "# Daily Docker volume backup at 2 AM"
echo "0 2 * * * /path/to/automated-backup.sh >> /var/log/docker-backup.log 2>&1"
```

## 🔧 Performance Considerations

### Volume Performance Comparison

```bash
# Test volume performance
docker run --rm \
  -v test-volume:/data \
  ubuntu dd if=/dev/zero of=/data/test bs=1M count=100

# Test bind mount performance
mkdir -p /tmp/bind-test
docker run --rm \
  -v /tmp/bind-test:/data \
  ubuntu dd if=/dev/zero of=/data/test bs=1M count=100

# Test tmpfs performance
docker run --rm \
  --tmpfs /data \
  ubuntu dd if=/dev/zero of=/data/test bs=1M count=100
```

### Storage Driver Optimization

```bash
# Check current storage driver
docker info | grep "Storage Driver"

# Volume mount options for performance
docker run -d \
  -v myvolume:/data:rw,Z \
  myapp

# Read-only mounts for security
docker run -d \
  -v config-volume:/app/config:ro \
  myapp
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Understand the difference between volumes, bind mounts, and tmpfs
- [ ] Create and manage Docker volumes effectively
- [ ] Share data between multiple containers
- [ ] Implement backup and restore strategies
- [ ] Choose the right storage type for different use cases

## 🚀 What's Next?

Excellent! You've mastered data persistence with Docker volumes. In the next lesson, we'll explore [Configuration Management](04-configuration-management.md) where you'll learn how to manage application configuration, environment variables, and secrets across different environments.

## 📝 Quick Reference Card

```bash
# Volume Management
docker volume create volume-name           # Create volume
docker volume ls                          # List volumes
docker volume inspect volume-name         # Inspect volume
docker volume rm volume-name              # Remove volume
docker volume prune                       # Remove unused volumes

# Using Volumes
docker run -v volume-name:/path image     # Named volume
docker run -v /host/path:/container/path image  # Bind mount
docker run --tmpfs /path image            # tmpfs mount

# Backup and Restore
docker run --rm -v vol:/data -v $(pwd):/backup ubuntu tar czf /backup/backup.tar.gz -C /data .
docker run --rm -v vol:/data -v $(pwd):/backup ubuntu tar xzf /backup/backup.tar.gz -C /data
```

---

*"Data is the new oil, but unlike oil, data doesn't get consumed when used - as long as you store it properly!"* - Your data is now safe and persistent! 💾
