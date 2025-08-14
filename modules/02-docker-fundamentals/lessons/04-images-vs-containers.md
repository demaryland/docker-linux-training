# 📦 Lesson 4: Images vs Containers - The Blueprint vs The Building

*"Understanding the difference between the recipe and the cake"*

One of the most important concepts to master in Docker is the relationship between images and containers. If you've been confused about when to use `docker images` vs `docker ps`, or wondering why you can run multiple containers from the same image, this lesson will clear everything up!

## 🎯 What You'll Learn

- The fundamental difference between Docker images and containers
- How images are like blueprints and containers are like buildings
- Managing Docker images effectively
- Understanding image layers and tags
- Working with Docker Hub registry
- Best practices for image and container management

## 🏗️ The Blueprint vs Building Analogy

### Images = Blueprints
Think of a Docker **image** like an architectural blueprint:
- Contains all the instructions for building something
- Can be used to create multiple identical buildings
- Doesn't change when you build from it
- Can be shared with others
- Stored in a library (registry) for reuse

### Containers = Buildings
Think of a Docker **container** like a building constructed from a blueprint:
- Created from an image (blueprint)
- Each building is independent
- Can be modified without affecting the blueprint
- Can be torn down and rebuilt
- Multiple buildings can be made from the same blueprint

### Visual Representation

```
Docker Image (nginx:alpine)
┌─────────────────────────┐
│     📋 Blueprint        │
│  ┌─────────────────┐    │
│  │ nginx software  │    │
│  │ Alpine Linux    │    │
│  │ Configuration   │    │
│  │ Dependencies    │    │
│  └─────────────────┘    │
└─────────────────────────┘
            │
            ├─── docker run ───┐
            │                  │
            ▼                  ▼
    Container 1            Container 2
┌─────────────────┐  ┌─────────────────┐
│  🏢 Building    │  │  🏢 Building    │
│  nginx:8080     │  │  nginx:8081     │
│  (running)      │  │  (running)      │
└─────────────────┘  └─────────────────┘
```

## 📦 Understanding Docker Images

### What's in an Image?

A Docker image contains:
- **Base operating system** (like Alpine Linux, Ubuntu)
- **Application code** (your web app, database, etc.)
- **Dependencies** (libraries, runtime environments)
- **Configuration files** (settings, environment variables)
- **Metadata** (labels, exposed ports, default commands)

### Image Layers

Images are built in layers, like a stack of pancakes:

```
┌─────────────────────────┐ ← Your application layer
├─────────────────────────┤ ← Dependencies layer
├─────────────────────────┤ ← Runtime layer (Node.js, Python, etc.)
├─────────────────────────┤ ← Package manager layer
└─────────────────────────┘ ← Base OS layer (Alpine, Ubuntu)
```

**Benefits of layers:**
- **Efficiency**: Shared layers save disk space
- **Speed**: Only changed layers need to be downloaded
- **Caching**: Build process can reuse unchanged layers

### Image Tags

Images can have multiple tags (like version numbers):

```bash
nginx:latest        # Latest version
nginx:1.21         # Specific version
nginx:alpine       # Alpine Linux variant
nginx:1.21-alpine  # Specific version with Alpine
```

## 🧪 Lab 4: Exploring Images and Containers

Let's explore the relationship between images and containers!

### Task 1: Working with Images

1. **List current images:**
   ```bash
   docker images
   ```

2. **Pull some images without running them:**
   ```bash
   docker pull nginx:alpine
   docker pull nginx:latest
   docker pull python:3.9
   docker pull redis:alpine
   ```

3. **List images again:**
   ```bash
   docker images
   ```

   Notice how you now have multiple images with different tags.

4. **Get detailed information about an image:**
   ```bash
   docker inspect nginx:alpine
   docker history nginx:alpine
   ```

### Task 2: One Image, Multiple Containers

1. **Create multiple containers from the same nginx image:**
   ```bash
   docker run -d --name web1 -p 8081:80 nginx:alpine
   docker run -d --name web2 -p 8082:80 nginx:alpine
   docker run -d --name web3 -p 8083:80 nginx:alpine
   ```

2. **Check all containers are running:**
   ```bash
   docker ps
   ```

   You should see three nginx containers running!

3. **Test each web server:**
   ```bash
   curl http://localhost:8081
   curl http://localhost:8082
   curl http://localhost:8083
   ```

4. **Modify one container without affecting others:**
   ```bash
   docker exec web1 sh -c 'echo "<h1>Web Server 1</h1>" > /usr/share/nginx/html/index.html'
   docker exec web2 sh -c 'echo "<h1>Web Server 2</h1>" > /usr/share/nginx/html/index.html'
   ```

5. **Test the differences:**
   ```bash
   curl http://localhost:8081
   curl http://localhost:8082
   curl http://localhost:8083  # This one unchanged
   ```

6. **Clean up:**
   ```bash
   docker stop web1 web2 web3
   docker rm web1 web2 web3
   ```

### Task 3: Image Management

1. **Search for images on Docker Hub:**
   ```bash
   docker search python
   docker search database
   ```

2. **Pull specific image versions:**
   ```bash
   docker pull python:3.8
   docker pull python:3.9
   docker pull python:3.10
   ```

3. **Compare image sizes:**
   ```bash
   docker images | grep python
   ```

4. **Remove unused images:**
   ```bash
   docker rmi python:3.8
   docker images | grep python
   ```

### Task 4: Understanding Image Layers

1. **Examine image layers:**
   ```bash
   docker history nginx:alpine
   ```

   This shows how the image was built, layer by layer.

2. **Pull a larger image and watch the layers:**
   ```bash
   docker pull ubuntu:20.04
   ```

   Notice how Docker downloads multiple layers.

3. **Compare layer sharing:**
   ```bash
   docker pull ubuntu:22.04
   ```

   Some layers might be shared between Ubuntu versions!

## 🔄 Container Lifecycle Deep Dive

### Container States Explained

```
┌─────────┐  docker run   ┌─────────┐  docker stop   ┌─────────┐
│ Created │ ────────────▶ │ Running │ ─────────────▶ │ Stopped │
└─────────┘               └─────────┘                └─────────┘
     │                         │                          │
     │                         │ docker pause             │
     │                         ▼                          │
     │                    ┌─────────┐                     │
     │                    │ Paused  │                     │
     │                    └─────────┘                     │
     │                         │                          │
     │                         │ docker unpause           │
     │                         ▼                          │
     │                    ┌─────────┐                     │
     └─── docker start ──│ Running │◀─── docker start ───┘
                         └─────────┘
```

### Advanced Container Management

```bash
# Create container without starting it
docker create --name my-container nginx:alpine

# Start the created container
docker start my-container

# Attach to running container (see output)
docker attach my-container

# Copy files to/from containers
docker cp file.txt my-container:/app/
docker cp my-container:/app/file.txt ./

# View container resource usage
docker stats my-container

# View processes running in container
docker top my-container
```

## 🧪 Lab 4 Continued: Advanced Container Operations

### Task 5: Container Data and Changes

1. **Run a container and make changes:**
   ```bash
   docker run -it --name data-test ubuntu:20.04 bash
   ```

2. **Inside the container, create some data:**
   ```bash
   echo "Important data" > /tmp/mydata.txt
   apt update && apt install -y curl
   curl --version
   exit
   ```

3. **Container is stopped but data still exists:**
   ```bash
   docker ps -a | grep data-test
   ```

4. **Start the container again and check data:**
   ```bash
   docker start data-test
   docker exec data-test cat /tmp/mydata.txt
   docker exec data-test curl --version
   ```

   The data and installed software are still there!

5. **Remove the container:**
   ```bash
   docker stop data-test
   docker rm data-test
   ```

   Now all the data and changes are gone forever.

### Task 6: Image vs Container Comparison

1. **Check current images and containers:**
   ```bash
   docker images
   docker ps -a
   ```

2. **Run the same image multiple times:**
   ```bash
   docker run -d --name app1 nginx:alpine
   docker run -d --name app2 nginx:alpine
   docker run -d --name app3 nginx:alpine
   ```

3. **Modify each container differently:**
   ```bash
   docker exec app1 sh -c 'echo "App 1 Content" > /usr/share/nginx/html/index.html'
   docker exec app2 sh -c 'echo "App 2 Content" > /usr/share/nginx/html/index.html'
   docker exec app3 sh -c 'echo "App 3 Content" > /usr/share/nginx/html/index.html'
   ```

4. **Verify they're all different:**
   ```bash
   docker exec app1 cat /usr/share/nginx/html/index.html
   docker exec app2 cat /usr/share/nginx/html/index.html
   docker exec app3 cat /usr/share/nginx/html/index.html
   ```

5. **But the original image is unchanged:**
   ```bash
   docker run --rm nginx:alpine cat /usr/share/nginx/html/index.html
   ```

6. **Clean up:**
   ```bash
   docker stop app1 app2 app3
   docker rm app1 app2 app3
   ```

## 🌐 Working with Docker Hub

### What is Docker Hub?

Docker Hub is the default public registry for Docker images. It's like GitHub for Docker images - you can find, download, and share container images.

### Finding Images

1. **Search from command line:**
   ```bash
   docker search mysql
   docker search "web server"
   ```

2. **Visit Docker Hub in browser:**
   - Go to https://hub.docker.com
   - Search for images
   - Read documentation and reviews
   - Check download statistics

### Understanding Image Names

Docker image names follow this format:
```
[registry/]namespace/repository:tag
```

**Examples:**
```bash
nginx                           # Official nginx image (latest tag)
nginx:alpine                    # Official nginx with alpine tag
mysql:8.0                      # Official MySQL version 8.0
redis:6-alpine                 # Official Redis version 6 with alpine
ubuntu:20.04                   # Official Ubuntu 20.04
```

### Official vs Community Images

- **Official Images**: Maintained by Docker and the software vendors
- **Community Images**: Created by the community
- **Verified Publisher**: Images from verified organizations

**Always prefer official images when available!**

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Explain the difference between images and containers
- [ ] Run multiple containers from the same image
- [ ] Manage container lifecycle (create, start, stop, remove)
- [ ] Understand how container changes don't affect images
- [ ] Search for and pull images from Docker Hub
- [ ] Use image tags effectively
- [ ] View image layers and history

## 🎯 Final Challenge: Image and Container Mastery

Complete this comprehensive challenge:

1. **Pull three different versions of Python**
2. **Run containers from each version to verify they're different**
3. **Create a long-running container and modify it**
4. **Demonstrate that the original image is unchanged**
5. **Clean up all containers but keep the images**

**Solution:**
```bash
# 1. Pull different Python versions
docker pull python:3.8-alpine
docker pull python:3.9-alpine
docker pull python:3.10-alpine

# 2. Test each version
docker run --rm python:3.8-alpine python --version
docker run --rm python:3.9-alpine python --version
docker run --rm python:3.10-alpine python --version

# 3. Create and modify a container
docker run -it --name py-test python:3.9-alpine sh
# (inside) pip install requests
# (inside) python -c "import requests; print('Requests installed!')"
# (inside) exit

# 4. Show original image unchanged
docker run --rm python:3.9-alpine python -c "import requests"
# This should fail - requests not in original image

# But our container still has it
docker start py-test
docker exec py-test python -c "import requests; print('Still here!')"

# 5. Clean up containers, keep images
docker stop py-test
docker rm py-test
docker images | grep python  # Images still there
```

## 🚀 What's Next?

Perfect! You now understand the crucial difference between images and containers. In the next lesson, [Running Web Services in Containers](05-web-services.md), we'll put this knowledge to work by deploying real web applications in containers.

## 📝 Quick Reference Card

```bash
# Image management
docker images                   # List local images
docker pull image:tag          # Download image
docker rmi image:tag           # Remove image
docker history image           # Show image layers
docker inspect image           # Image details

# Container from image
docker run image               # Create and start container
docker create image            # Create container (don't start)
docker start container         # Start created/stopped container

# Container management
docker ps                      # Running containers
docker ps -a                   # All containers
docker stop container          # Stop container
docker rm container            # Remove container

# Container inspection
docker logs container          # Container logs
docker inspect container       # Container details
docker stats container         # Resource usage
docker top container           # Running processes
```

## 🌟 Key Takeaways

```
📋 Images are templates, containers are instances
🏗️ One image can create many containers
💾 Container changes don't affect the original image
🔄 Containers can be stopped, started, and removed
📦 Images are stored in registries like Docker Hub
🏷️ Tags help manage different versions of images
```

## 🤔 Common Misconceptions Clarified

### "If I modify a container, does it change the image?"
**No!** Containers are independent instances. Changes to a container don't affect the original image.

### "Can I run multiple containers from the same image?"
**Yes!** That's one of the main benefits. Each container is independent.

### "Do I need to download an image every time I run it?"
**No!** Once downloaded, the image stays on your system until you remove it.

### "Are containers just running images?"
**Not exactly.** Containers are instances created from images, with their own writable layer.

---

*"Understanding images vs containers is like understanding the difference between a recipe and a meal - one creates the other, but they're fundamentally different things."* 🍰
