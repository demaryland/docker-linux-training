# 🚀 Lesson 3: Your First Container Adventure

*"Hello World, meet Hello Container!"*

Time for the fun part! You've learned the theory and verified your installation - now let's actually run some containers. This is where Docker transforms from an abstract concept into a powerful tool you can see in action.

## 🎯 What You'll Learn

- Running your first containers
- Understanding the `docker run` command and its options
- Interactive vs detached containers
- Managing container lifecycle (start, stop, remove)
- Viewing container logs and information
- Basic container troubleshooting

## 🐳 The `docker run` Command

The `docker run` command is your gateway to containers. It's like the Swiss Army knife of Docker - it can do almost everything you need to get started.

### Basic Syntax

```bash
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

**Examples:**
```bash
docker run hello-world                    # Run hello-world container
docker run ubuntu:20.04 echo "Hello!"    # Run Ubuntu and execute echo command
docker run -it ubuntu:20.04 bash         # Run Ubuntu interactively with bash
```

### Common Options

| Option | Description | Example |
|--------|-------------|---------|
| `-it` | Interactive with terminal | `docker run -it ubuntu bash` |
| `-d` | Detached (background) | `docker run -d nginx` |
| `--name` | Give container a name | `docker run --name myapp nginx` |
| `-p` | Port mapping | `docker run -p 8080:80 nginx` |
| `--rm` | Remove when stopped | `docker run --rm ubuntu echo "hi"` |
| `-e` | Environment variable | `docker run -e VAR=value ubuntu` |

## 🧪 Lab 3: Your First Container Adventures

Let's start with simple containers and work our way up!

### Task 1: The Classic Hello World

1. **Run the hello-world container:**
   ```bash
   docker run hello-world
   ```

   **What happened?**
   - Docker looked for the `hello-world` image locally
   - Didn't find it, so downloaded it from Docker Hub
   - Created a container from the image
   - Ran the container (which printed a message)
   - Container exited automatically

2. **Check what images you now have:**
   ```bash
   docker images
   ```

3. **Check container history:**
   ```bash
   docker ps -a
   ```

   You'll see the hello-world container in "Exited" status.

### Task 2: Interactive Containers

1. **Run an interactive Ubuntu container:**
   ```bash
   docker run -it ubuntu:20.04 bash
   ```

   The `-it` flags mean:
   - `-i`: Interactive (keep STDIN open)
   - `-t`: Allocate a pseudo-TTY (terminal)

2. **Inside the container, explore:**
   ```bash
   whoami              # You're root!
   hostname            # Random container hostname
   cat /etc/os-release # Ubuntu version info
   ls /                # Container file system
   ps aux              # Running processes
   ```

3. **Install something in the container:**
   ```bash
   apt update
   apt install -y cowsay
   /usr/games/cowsay "Hello from inside a container!"
   ```

4. **Exit the container:**
   ```bash
   exit
   ```

5. **Back on your host, check what happened:**
   ```bash
   docker ps           # No running containers
   docker ps -a        # Shows your exited Ubuntu container
   ```

### Task 3: Detached Containers

1. **Run a web server in the background:**
   ```bash
   docker run -d --name my-nginx nginx:alpine
   ```

   The `-d` flag runs the container in detached mode (background).

2. **Check if it's running:**
   ```bash
   docker ps
   ```

   You should see nginx running!

3. **Get detailed information about the container:**
   ```bash
   docker inspect my-nginx
   ```

4. **View the container logs:**
   ```bash
   docker logs my-nginx
   ```

5. **Stop the container:**
   ```bash
   docker stop my-nginx
   ```

6. **Start it again:**
   ```bash
   docker start my-nginx
   ```

### Task 4: Port Mapping

1. **Run nginx with port mapping:**
   ```bash
   docker run -d --name web-server -p 8080:80 nginx:alpine
   ```

   This maps port 8080 on your host to port 80 in the container.

2. **Test the web server:**
   ```bash
   curl http://localhost:8080
   ```

   You should see the nginx welcome page HTML!

3. **View the logs:**
   ```bash
   docker logs web-server
   ```

   You'll see the HTTP request logged.

### Task 5: Temporary Containers

1. **Run a container that removes itself when done:**
   ```bash
   docker run --rm ubuntu:20.04 echo "This container will self-destruct!"
   ```

2. **Check if it's gone:**
   ```bash
   docker ps -a | grep ubuntu
   ```

   The `--rm` flag automatically removed it after execution.

## 🔄 Container Lifecycle Management

### Container States

Containers can be in several states:
- **Created** - Container exists but hasn't been started
- **Running** - Container is currently executing
- **Paused** - Container processes are paused
- **Stopped** - Container has exited
- **Removed** - Container has been deleted

### Essential Lifecycle Commands

```bash
# Create and run
docker run [options] image              # Create and start container

# Control running containers
docker stop container_name              # Gracefully stop container
docker kill container_name              # Force stop container
docker start container_name             # Start stopped container
docker restart container_name           # Restart container
docker pause container_name             # Pause container
docker unpause container_name           # Unpause container

# Information
docker ps                              # List running containers
docker ps -a                           # List all containers
docker logs container_name             # View container logs
docker inspect container_name          # Detailed container info

# Cleanup
docker rm container_name               # Remove stopped container
docker rm -f container_name            # Force remove running container
```

## 🧪 Lab 3 Continued: Container Management Practice

### Task 6: Container Lifecycle Practice

1. **Create a long-running container:**
   ```bash
   docker run -d --name sleepy-app alpine:latest sleep 300
   ```

   This runs a container that just sleeps for 300 seconds.

2. **Check it's running:**
   ```bash
   docker ps
   ```

3. **Pause the container:**
   ```bash
   docker pause sleepy-app
   docker ps
   ```

   Notice the status shows "Paused".

4. **Unpause it:**
   ```bash
   docker unpause sleepy-app
   docker ps
   ```

5. **Stop the container:**
   ```bash
   docker stop sleepy-app
   ```

6. **Try to start it again:**
   ```bash
   docker start sleepy-app
   docker ps
   ```

7. **Remove the container:**
   ```bash
   docker rm sleepy-app
   ```

### Task 7: Working with Container Logs

1. **Run a container that generates logs:**
   ```bash
   docker run -d --name log-generator alpine:latest sh -c 'while true; do echo "Log entry at $(date)"; sleep 2; done'
   ```

2. **View the logs:**
   ```bash
   docker logs log-generator
   ```

3. **Follow the logs in real-time:**
   ```bash
   docker logs -f log-generator
   ```

   Press `Ctrl+C` to stop following.

4. **View only the last 5 log lines:**
   ```bash
   docker logs --tail 5 log-generator
   ```

5. **View logs with timestamps:**
   ```bash
   docker logs -t log-generator
   ```

6. **Clean up:**
   ```bash
   docker stop log-generator
   docker rm log-generator
   ```

## 🔧 Executing Commands in Running Containers

Sometimes you need to run commands inside a running container:

### The `docker exec` Command

```bash
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

**Examples:**
```bash
docker exec container_name ls /app           # Run ls command
docker exec -it container_name bash          # Get interactive shell
docker exec -u root container_name whoami    # Run as specific user
```

### Lab Task: Container Debugging

1. **Start a web server:**
   ```bash
   docker run -d --name debug-nginx -p 8081:80 nginx:alpine
   ```

2. **Execute commands inside the running container:**
   ```bash
   docker exec debug-nginx ls /etc/nginx
   docker exec debug-nginx cat /etc/nginx/nginx.conf
   docker exec debug-nginx ps aux
   ```

3. **Get an interactive shell:**
   ```bash
   docker exec -it debug-nginx sh
   ```

4. **Inside the container:**
   ```bash
   ls /usr/share/nginx/html
   cat /usr/share/nginx/html/index.html
   echo "<h1>Modified by exec!</h1>" > /usr/share/nginx/html/index.html
   exit
   ```

5. **Test the change:**
   ```bash
   curl http://localhost:8081
   ```

6. **Clean up:**
   ```bash
   docker stop debug-nginx
   docker rm debug-nginx
   ```

## 🤔 Common Container Scenarios

### "My container exited immediately"

**Problem:** Container starts then stops right away.

**Debugging steps:**
```bash
# Check the exit code and logs
docker ps -a                    # Look for exit code
docker logs container_name      # Check what happened

# Run interactively to debug
docker run -it image_name bash  # Get shell to investigate
```

### "I can't connect to my containerized service"

**Problem:** Service running in container but can't access it.

**Solutions:**
```bash
# Check if container is running
docker ps

# Check port mapping
docker port container_name

# Test from inside the container
docker exec container_name curl localhost:80

# Check logs for errors
docker logs container_name
```

### "My container is using too much memory"

**Problem:** Container consuming excessive resources.

**Solutions:**
```bash
# Check resource usage
docker stats container_name

# Run with memory limits
docker run -m 512m image_name

# Check what's running inside
docker exec container_name ps aux
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Run containers interactively and in detached mode
- [ ] Use common `docker run` options
- [ ] Manage container lifecycle (start, stop, remove)
- [ ] View and follow container logs
- [ ] Execute commands in running containers
- [ ] Map ports from containers to host
- [ ] Troubleshoot basic container issues

## 🎯 Final Challenge: Container Management

Create a complete container workflow:

1. **Run a web server with custom name and port mapping**
2. **Verify it's working by accessing the web page**
3. **Execute commands inside the running container**
4. **View and follow the logs**
5. **Stop and restart the container**
6. **Clean up everything**

**Solution:**
```bash
# 1. Run web server
docker run -d --name my-web -p 8080:80 nginx:alpine

# 2. Test it works
curl http://localhost:8080

# 3. Execute commands inside
docker exec my-web ls /etc/nginx
docker exec -it my-web sh
# (inside container) echo "Hello from container" > /usr/share/nginx/html/hello.txt
# (inside container) exit

# 4. View logs
docker logs my-web
curl http://localhost:8080/hello.txt

# 5. Stop and restart
docker stop my-web
docker start my-web
curl http://localhost:8080  # Should work again

# 6. Clean up
docker stop my-web
docker rm my-web
docker rmi nginx:alpine  # Optional: remove image
```

## 🚀 What's Next?

Excellent! You've mastered the basics of running and managing containers. In the next lesson, [Images vs Containers - The Blueprint vs The Building](04-images-vs-containers.md), we'll dive deeper into understanding the relationship between Docker images and containers.

## 📝 Quick Reference Card

```bash
# Run containers
docker run image                    # Basic run
docker run -it image bash          # Interactive
docker run -d image                 # Detached
docker run --name myapp image       # Named container
docker run -p 8080:80 image        # Port mapping
docker run --rm image               # Auto-remove

# Manage containers
docker ps                          # List running
docker ps -a                       # List all
docker stop container              # Stop gracefully
docker start container             # Start stopped
docker restart container           # Restart
docker rm container                # Remove

# Interact with containers
docker logs container              # View logs
docker logs -f container           # Follow logs
docker exec -it container bash     # Get shell
docker inspect container           # Detailed info
```

## 🌟 Pro Tips

1. **Use meaningful names:** `--name web-server` instead of random names
2. **Always check logs** when containers don't behave as expected
3. **Use `--rm` for temporary containers** to avoid clutter
4. **Map ports explicitly** with `-p host:container` for web services
5. **Use `docker exec`** to debug running containers

---

*"Every container expert started with their first `docker run` command."* - You're now officially a container captain! 🚢
