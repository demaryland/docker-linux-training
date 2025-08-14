# 🌐 Lesson 5: Running Web Services in Containers

*"Your first containerized web server"*

Now for the exciting part - running real web services in containers! This is where Docker really shines in IT operations. Instead of spending hours installing and configuring web servers, you'll have them running in minutes. Let's deploy some web services and see the magic happen!

## 🎯 What You'll Learn

- Deploying web servers in containers
- Understanding port mapping and networking basics
- Accessing containerized web applications
- Managing multiple web services
- Basic load balancing concepts
- Troubleshooting web service containers

## 🌐 Web Services in Containers

### Why Containerize Web Services?

**Traditional Web Server Setup:**
1. Install operating system
2. Install web server software
3. Configure web server
4. Install dependencies
5. Deploy application code
6. Configure networking
7. Set up monitoring
8. Hope it all works together!

**Containerized Web Server:**
1. `docker run -p 80:80 nginx`
2. Done! 🎉

### Common Web Services You Can Containerize

- **Web Servers**: nginx, Apache HTTP Server
- **Application Servers**: Node.js, Python Flask/Django, Java Spring
- **Databases**: MySQL, PostgreSQL, MongoDB, Redis
- **Reverse Proxies**: nginx, HAProxy, Traefik
- **Content Management**: WordPress, Drupal
- **Development Tools**: phpMyAdmin, Adminer

## 🚀 Port Mapping Deep Dive

### Understanding Ports

**Ports** are like doors to your computer:
- Each service listens on a specific port
- Port 80 = HTTP web traffic
- Port 443 = HTTPS secure web traffic
- Port 22 = SSH
- Port 3306 = MySQL database

### Docker Port Mapping

When you run a container, it has its own network space. To access services inside the container, you need to map ports:

```bash
docker run -p HOST_PORT:CONTAINER_PORT image
```

**Examples:**
```bash
docker run -p 8080:80 nginx        # Host port 8080 → Container port 80
docker run -p 3000:3000 node-app   # Host port 3000 → Container port 3000
docker run -p 80:80 nginx          # Host port 80 → Container port 80
```

### Port Mapping Scenarios

```
Host System (Your Computer)
┌─────────────────────────────────┐
│  Port 8080 ──┐                 │
│  Port 8081 ──┼─────────────────┤
│  Port 8082 ──┘                 │
└─────────────────────────────────┘
       │        │        │
       ▼        ▼        ▼
   Container1 Container2 Container3
   ┌────────┐ ┌────────┐ ┌────────┐
   │Port 80 │ │Port 80 │ │Port 80 │
   │ nginx  │ │ nginx  │ │ nginx  │
   └────────┘ └────────┘ └────────┘
```

## 🧪 Lab 5: Web Services Deployment

Let's deploy various web services and learn how they work!

### Task 1: Basic Web Server Deployment

1. **Deploy nginx web server:**
   ```bash
   docker run -d --name my-nginx -p 8080:80 nginx:alpine
   ```

2. **Test the web server:**
   ```bash
   curl http://localhost:8080
   ```

   You should see the nginx welcome page HTML.

3. **Check the container status:**
   ```bash
   docker ps
   docker logs my-nginx
   ```

4. **Access the web server from VS Code:**
   - Look for the "Ports" tab in VS Code
   - Port 8080 should be listed and forwarded
   - Click the globe icon to open in browser

### Task 2: Custom Web Content

1. **Create a simple HTML file:**
   ```bash
   mkdir ~/web-content
   cat > ~/web-content/index.html << 'EOF'
   <!DOCTYPE html>
   <html>
   <head>
       <title>My First Containerized Website</title>
       <style>
           body { font-family: Arial, sans-serif; margin: 40px; }
           .container { max-width: 800px; margin: 0 auto; }
           .highlight { background-color: #f0f8ff; padding: 20px; border-radius: 5px; }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>🐳 Welcome to My Containerized Website!</h1>
           <div class="highlight">
               <p>This website is running inside a Docker container!</p>
               <p>Server: nginx</p>
               <p>Container ID: <span id="hostname"></span></p>
           </div>
           <h2>What's Amazing About This?</h2>
           <ul>
               <li>✅ Deployed in seconds, not hours</li>
               <li>✅ Runs the same everywhere</li>
               <li>✅ Easy to scale and manage</li>
               <li>✅ Isolated from other services</li>
           </ul>
       </div>
       <script>
           // Show container hostname
           fetch('/hostname.txt').then(r => r.text()).then(h => {
               document.getElementById('hostname').textContent = h;
           }).catch(() => {
               document.getElementById('hostname').textContent = 'Unknown';
           });
       </script>
   </body>
   </html>
   EOF
   ```

2. **Run nginx with your custom content:**
   ```bash
   docker run -d --name custom-web -p 8081:80 -v ~/web-content:/usr/share/nginx/html nginx:alpine
   ```

3. **Test your custom website:**
   ```bash
   curl http://localhost:8081
   ```

   You should see your custom HTML!

### Task 3: Multiple Web Services

1. **Deploy multiple different web services:**
   ```bash
   # Apache HTTP Server
   docker run -d --name apache-web -p 8082:80 httpd:alpine
   
   # Simple Python web server
   docker run -d --name python-web -p 8083:8000 python:3.9-alpine sh -c 'python -m http.server 8000'
   
   # Node.js web server
   docker run -d --name node-web -p 8084:3000 node:16-alpine sh -c 'echo "const http = require(\"http\"); http.createServer((req, res) => { res.writeHead(200, {\"Content-Type\": \"text/html\"}); res.end(\"<h1>Hello from Node.js Container!</h1><p>Port: 3000</p>\"); }).listen(3000, () => console.log(\"Server running on port 3000\"));" > server.js && node server.js'
   ```

2. **Check all services are running:**
   ```bash
   docker ps
   ```

3. **Test each service:**
   ```bash
   curl http://localhost:8080  # nginx
   curl http://localhost:8081  # custom nginx
   curl http://localhost:8082  # apache
   curl http://localhost:8083  # python
   curl http://localhost:8084  # node.js
   ```

4. **View logs from different services:**
   ```bash
   docker logs my-nginx
   docker logs apache-web
   docker logs python-web
   ```

### Task 4: Database Services

1. **Deploy a MySQL database:**
   ```bash
   docker run -d --name mysql-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=mypassword mysql:8.0
   ```

2. **Deploy a Redis cache:**
   ```bash
   docker run -d --name redis-cache -p 6379:6379 redis:alpine
   ```

3. **Check database containers:**
   ```bash
   docker ps | grep -E "(mysql|redis)"
   ```

4. **Test database connectivity:**
   ```bash
   # Test MySQL (wait a moment for it to start up)
   docker exec mysql-db mysql -uroot -pmypassword -e "SELECT 'Hello from MySQL!' as message;"
   
   # Test Redis
   docker exec redis-cache redis-cli ping
   ```

## 🔧 Container Networking Basics

### Default Docker Networking

By default, Docker creates a bridge network where:
- Containers can communicate with each other by name
- Containers can access the internet
- Host can access containers through port mapping

### Container-to-Container Communication

1. **Create a network for your containers:**
   ```bash
   docker network create my-network
   ```

2. **Run containers on the same network:**
   ```bash
   docker run -d --name web-app --network my-network nginx:alpine
   docker run -d --name database --network my-network mysql:8.0 -e MYSQL_ROOT_PASSWORD=secret
   ```

3. **Test communication between containers:**
   ```bash
   docker exec web-app ping database
   docker exec database ping web-app
   ```

## 🧪 Lab 5 Continued: Real-World Web Stack

Let's build a complete web application stack!

### Task 5: WordPress with MySQL

1. **Create a network for the application:**
   ```bash
   docker network create wordpress-net
   ```

2. **Deploy MySQL database:**
   ```bash
   docker run -d \
     --name wordpress-db \
     --network wordpress-net \
     -e MYSQL_ROOT_PASSWORD=rootpassword \
     -e MYSQL_DATABASE=wordpress \
     -e MYSQL_USER=wpuser \
     -e MYSQL_PASSWORD=wppassword \
     mysql:8.0
   ```

3. **Deploy WordPress:**
   ```bash
   docker run -d \
     --name wordpress-app \
     --network wordpress-net \
     -p 8090:80 \
     -e WORDPRESS_DB_HOST=wordpress-db \
     -e WORDPRESS_DB_USER=wpuser \
     -e WORDPRESS_DB_PASSWORD=wppassword \
     -e WORDPRESS_DB_NAME=wordpress \
     wordpress:latest
   ```

4. **Wait for services to start and test:**
   ```bash
   # Wait about 30 seconds for MySQL to initialize
   sleep 30
   
   # Check if services are running
   docker ps | grep wordpress
   
   # Test the application
   curl -I http://localhost:8090
   ```

5. **Access WordPress setup:**
   - Open http://localhost:8090 in your browser (through VS Code port forwarding)
   - You should see the WordPress setup page!

### Task 6: Monitoring Your Web Services

1. **Check resource usage:**
   ```bash
   docker stats
   ```

   Press `Ctrl+C` to exit.

2. **Check specific container stats:**
   ```bash
   docker stats wordpress-app --no-stream
   docker stats mysql-db --no-stream
   ```

3. **View detailed container information:**
   ```bash
   docker inspect wordpress-app | grep -A 10 "NetworkSettings"
   docker port wordpress-app
   ```

4. **Monitor logs in real-time:**
   ```bash
   docker logs -f wordpress-app
   ```

   In another terminal, access the website to see logs appear.

## 🔧 Troubleshooting Web Services

### Common Web Service Issues

### "Can't access my web service"

**Debugging steps:**
```bash
# 1. Check if container is running
docker ps | grep container_name

# 2. Check port mapping
docker port container_name

# 3. Test from inside the container
docker exec container_name curl localhost:80

# 4. Check container logs
docker logs container_name

# 5. Test network connectivity
curl -v http://localhost:8080
```

### "Service starts but immediately crashes"

**Debugging steps:**
```bash
# Check exit code and logs
docker ps -a | grep container_name
docker logs container_name

# Run interactively to debug
docker run -it image_name sh

# Check if required environment variables are set
docker inspect container_name | grep -A 10 "Env"
```

### "Database connection failed"

**Debugging steps:**
```bash
# Check if database container is running
docker ps | grep database

# Check database logs
docker logs database_container

# Test database connectivity
docker exec database_container mysql -u root -p

# Verify network connectivity between containers
docker exec web_container ping database_container
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Deploy web servers using Docker
- [ ] Map ports correctly for web access
- [ ] Run multiple web services on different ports
- [ ] Connect web applications to databases
- [ ] Monitor web service containers
- [ ] Troubleshoot common web service issues
- [ ] Understand basic container networking

## 🎯 Final Challenge: Complete Web Stack

Deploy a complete web application stack with:

1. **A reverse proxy** (nginx)
2. **A web application** (your choice)
3. **A database** (MySQL or PostgreSQL)
4. **Proper networking** between services
5. **Monitoring** and log access

**Example Solution:**
```bash
# Create network
docker network create webapp-net

# Deploy database
docker run -d --name app-db --network webapp-net \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=myapp \
  mysql:8.0

# Deploy web application (simple Python app)
docker run -d --name web-app --network webapp-net \
  python:3.9-alpine sh -c '
    echo "from http.server import HTTPServer, BaseHTTPRequestHandler
import json
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header(\"Content-type\", \"text/html\")
        self.end_headers()
        self.wfile.write(b\"<h1>Web App Container</h1><p>Connected to database: app-db</p>\")
server = HTTPServer((\"0.0.0.0\", 8000), Handler)
server.serve_forever()" > app.py && python app.py'

# Deploy reverse proxy
docker run -d --name reverse-proxy --network webapp-net -p 80:80 \
  nginx:alpine

# Test the stack
docker ps
curl http://localhost
```

## 🚀 What's Next?

Fantastic! You've successfully deployed web services in containers and understand the basics of container networking. You've completed Module 2 and earned your **"First Container Captain"** badge! 🚢

Your next adventure awaits in **Module 3: Building Your Container Empire**, where you'll learn to create your own custom Docker images instead of just using pre-built ones.

## 📝 Quick Reference Card

```bash
# Web server deployment
docker run -d -p 8080:80 nginx              # Basic web server
docker run -d -p 8080:80 --name web nginx   # Named web server
docker run -d -p 8080:80 -v ~/html:/usr/share/nginx/html nginx  # Custom content

# Database deployment
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=pass mysql:8.0
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=pass postgres:13
docker run -d -p 6379:6379 redis:alpine

# Networking
docker network create my-network            # Create network
docker run --network my-network image       # Run on network
docker exec container1 ping container2      # Test connectivity

# Monitoring
docker ps                                   # Running containers
docker logs container                       # View logs
docker logs -f container                    # Follow logs
docker stats                               # Resource usage
docker port container                       # Port mappings
```

## 🌟 Pro Tips

1. **Use specific ports** to avoid conflicts: `-p 8080:80` instead of `-p 80:80`
2. **Name your containers** meaningfully: `--name web-server`
3. **Check logs first** when services don't work: `docker logs container`
4. **Use networks** for multi-container applications
5. **Monitor resource usage** with `docker stats`
6. **Test connectivity** between containers with `ping`

## 🎊 Module 2 Complete!

You've successfully completed Docker Fundamentals! You now have:
- ✅ Container concept mastery
- ✅ Docker installation and setup knowledge
- ✅ Container lifecycle management skills
- ✅ Image vs container understanding
- ✅ Web service deployment capabilities

**Achievement Unlocked: First Container Captain** 🚢

Ready to build your own images? Let's move to Module 3! 🏗️

---

*"You've gone from container curious to container capable. The next step is becoming a container creator!"* - Onward to building your own images! 🐳
