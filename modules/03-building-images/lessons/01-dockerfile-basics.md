# 🏗️ Lesson 1: Your First Dockerfile - The Recipe for Containers

*"From consumer to creator - time to build your own!"*

Welcome to the exciting world of building your own Docker images! Up until now, you've been using pre-built images from Docker Hub - kind of like ordering takeout. Now you're going to learn to cook your own containers from scratch using Dockerfiles!

## 🎯 What You'll Learn

- What a Dockerfile is and why you need one
- Essential Dockerfile instructions
- How to build your first custom image
- Best practices for writing maintainable Dockerfiles

## 🍳 What is a Dockerfile?

Think of a Dockerfile as a recipe for creating a container image. Just like a cooking recipe tells you:
- What ingredients you need (base image)
- What steps to follow (commands to run)
- How to prepare everything (copy files, install software)

A Dockerfile tells Docker exactly how to build your custom image.

### Dockerfile vs. Image vs. Container

Let's clarify the relationship:

```
Dockerfile  →  Image  →  Container
(Recipe)    →  (Cake)  →  (Slice of cake)
```

- **Dockerfile**: The instructions/recipe
- **Image**: The built result (like a cake)
- **Container**: A running instance (like a slice you're eating)

## 📝 Essential Dockerfile Instructions

Let's learn the most important Dockerfile commands:

### `FROM` - Choose Your Base
*Every Dockerfile starts here*

```dockerfile
FROM ubuntu:20.04
FROM node:16-alpine
FROM nginx:alpine
```

This is like choosing your base ingredients. You're building on top of an existing image.

### `RUN` - Execute Commands
*Run commands during the build process*

```dockerfile
RUN apt-get update && apt-get install -y curl
RUN npm install
RUN echo "Hello World" > /tmp/hello.txt
```

Think of this as the cooking steps - what you do to prepare your image.

### `COPY` - Add Your Files
*Copy files from your computer into the image*

```dockerfile
COPY app.js /usr/src/app/
COPY . /usr/src/app/
COPY package*.json ./
```

This is like adding your own ingredients to the recipe.

### `WORKDIR` - Set Your Kitchen
*Set the working directory inside the container*

```dockerfile
WORKDIR /usr/src/app
```

This is like choosing which counter in your kitchen to work on.

### `EXPOSE` - Document Ports
*Tell others which ports your app uses*

```dockerfile
EXPOSE 3000
EXPOSE 80
```

This is like putting a label on your dish saying "serves 4 people."

### `CMD` - Default Command
*What runs when someone starts your container*

```dockerfile
CMD ["node", "app.js"]
CMD ["nginx", "-g", "daemon off;"]
```

This is like the serving instructions - how to "eat" your creation.

## 🧪 Lab 1: Your First Dockerfile

Let's build a simple web application! We'll create a basic HTML page served by nginx.

### Step 1: Create Your Project Directory

```bash
mkdir my-first-dockerfile
cd my-first-dockerfile
```

### Step 2: Create a Simple HTML File

Create a file called `index.html`:

```bash
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My First Docker Image!</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            background: linear-gradient(45deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 50px;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 10px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Congratulations!</h1>
        <h2>You built your first Docker image!</h2>
        <p>This webpage is running inside a container that YOU created!</p>
        <p>🐳 Docker + 🏗️ Your Skills = 🚀 Amazing!</p>
    </div>
</body>
</html>
EOF
```

### Step 3: Create Your Dockerfile

Create a file called `Dockerfile` (no extension!):

```bash
cat > Dockerfile << 'EOF'
# Use nginx as our base image
FROM nginx:alpine

# Copy our HTML file to nginx's web directory
COPY index.html /usr/share/nginx/html/

# Expose port 80 (nginx default)
EXPOSE 80

# nginx starts automatically, so no CMD needed
EOF
```

### Step 4: Build Your Image

```bash
docker build -t my-first-image .
```

**What's happening here?**
- `docker build`: The build command
- `-t my-first-image`: Tag (name) your image
- `.`: Use current directory as build context

### Step 5: Run Your Container

```bash
docker run -d -p 8080:80 --name my-first-container my-first-image
```

### Step 6: Test Your Creation

Open your browser and go to `http://localhost:8080`

You should see your beautiful webpage! 🎉

### Step 7: Clean Up

```bash
docker stop my-first-container
docker rm my-first-container
```

## 🧪 Lab 2: A Node.js Application

Let's build something more complex - a Node.js web application!

### Step 1: Create Project Structure

```bash
mkdir node-docker-app
cd node-docker-app
```

### Step 2: Create package.json

```bash
cat > package.json << 'EOF'
{
  "name": "docker-node-app",
  "version": "1.0.0",
  "description": "My first Node.js Docker app",
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
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Node.js in Docker!</title>
        <style>
          body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            background: #2c3e50; 
            color: white; 
            padding: 50px; 
          }
          .container {
            background: #34495e;
            padding: 30px;
            border-radius: 10px;
            display: inline-block;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🚀 Node.js + Docker = Awesome!</h1>
          <p>This Express server is running inside a Docker container!</p>
          <p>Container ID: ${process.env.HOSTNAME}</p>
          <p>Node.js Version: ${process.version}</p>
        </div>
      </body>
    </html>
  `);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://localhost:${port}`);
});
EOF
```

### Step 4: Create Dockerfile

```bash
cat > Dockerfile << 'EOF'
# Use Node.js as base image
FROM node:16-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose the port our app runs on
EXPOSE 3000

# Command to run our application
CMD ["npm", "start"]
EOF
```

### Step 5: Build and Run

```bash
# Build the image
docker build -t node-docker-app .

# Run the container
docker run -d -p 3000:3000 --name node-app node-docker-app

# Check if it's running
docker ps
```

### Step 6: Test Your App

Visit `http://localhost:3000` in your browser!

### Step 7: Check the Logs

```bash
docker logs node-app
```

You should see: "Server running at http://localhost:3000"

## 🔍 Understanding the Build Process

When you run `docker build`, here's what happens:

1. **Context**: Docker sends your current directory to the Docker daemon
2. **Base Image**: Downloads the FROM image if not already present
3. **Layers**: Each instruction creates a new layer
4. **Caching**: Docker reuses layers that haven't changed
5. **Final Image**: All layers combined into your new image

### Build Output Explained

```
Sending build context to Docker daemon  4.096kB
Step 1/6 : FROM node:16-alpine
 ---> a6b8b8b8b8b8
Step 2/6 : WORKDIR /usr/src/app
 ---> Running in c1d2e3f4g5h6
 ---> b7c8d9e0f1g2
Step 3/6 : COPY package*.json ./
 ---> h3i4j5k6l7m8
...
Successfully built n9o0p1q2r3s4
Successfully tagged node-docker-app:latest
```

Each step creates a layer, and Docker shows you the progress!

## 🎯 Best Practices for Beginners

### 1. Order Matters
Put instructions that change less frequently at the top:

```dockerfile
# Good: Dependencies change less than code
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
```

### 2. Use .dockerignore
Create a `.dockerignore` file to exclude unnecessary files:

```bash
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.DS_Store
EOF
```

### 3. Be Specific with COPY
Copy only what you need:

```dockerfile
# Better than COPY . .
COPY package*.json ./
COPY src/ ./src/
COPY public/ ./public/
```

### 4. Use Official Images
Start with official images when possible:

```dockerfile
FROM node:16-alpine    # Official Node.js image
FROM nginx:alpine      # Official nginx image
FROM python:3.9-slim   # Official Python image
```

## 🤔 Common "Oops!" Moments

### "My build is really slow!"
**Solution:** Order your Dockerfile instructions properly. Put changing files last.

### "Docker can't find my files!"
**Solution:** Make sure files are in the build context (current directory) and check your COPY paths.

### "My container exits immediately!"
**Solution:** Make sure your CMD instruction runs a long-running process, not a command that exits.

### "I can't access my application!"
**Solution:** Check that you're exposing the right port and mapping it correctly with `-p`.

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Write a basic Dockerfile with FROM, COPY, RUN, EXPOSE, and CMD
- [ ] Build an image using `docker build`
- [ ] Run a container from your custom image
- [ ] Understand the difference between Dockerfile, image, and container
- [ ] Use .dockerignore to exclude files

## 🚀 What's Next?

Excellent work! You've built your first custom Docker images. In the next lesson, we'll dive into [Advanced Dockerfile Techniques](02-advanced-dockerfile.md) where you'll learn about multi-stage builds, build arguments, and optimization techniques.

## 📝 Quick Reference Card

```dockerfile
# Essential Dockerfile Instructions
FROM image:tag              # Base image
WORKDIR /path              # Set working directory
COPY source dest           # Copy files from host
RUN command                # Execute command during build
EXPOSE port                # Document exposed ports
CMD ["command", "arg"]     # Default command to run
```

```bash
# Essential Build Commands
docker build -t name:tag .        # Build image with tag
docker build --no-cache .         # Build without using cache
docker images                     # List built images
docker rmi image:tag              # Remove image
```

---

*"Every expert was once a beginner. Every pro was once an amateur. Every icon was once an unknown."* - You just took your first step from Docker consumer to Docker creator! 🏗️
