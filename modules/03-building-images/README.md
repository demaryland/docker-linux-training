# 🏗️ Module 3: Building Your Container Empire

*"From consumer to creator - building your own containers"*

Welcome to the exciting world of creating your own Docker images! Up until now, you've been using pre-built images from Docker Hub. Now it's time to become a container creator and build custom images tailored to your specific needs.

## 🎯 Learning Objectives

By the end of this module, you'll be able to:
- Write effective Dockerfiles from scratch
- Build custom Docker images for your applications
- Understand Docker image layers and optimization
- Work with Red Hat Universal Base Images (UBI)
- Implement multi-stage builds for efficiency
- Follow best practices for image security and size
- Publish images to registries

## 📚 Module Contents

### 📝 [Lesson 1: Introduction to Dockerfiles](lessons/01-dockerfile-basics.md)
*"Your recipe for creating containers"*
- Understanding Dockerfile syntax
- Essential Dockerfile instructions
- Building your first custom image
- **Lab**: Create a simple web application image

### 🏗️ [Lesson 2: Advanced Dockerfile Techniques](lessons/02-advanced-dockerfile.md)
*"Mastering the art of image building"*
- Multi-stage builds for optimization
- Working with build arguments and environment variables
- Copying files and setting permissions
- **Lab**: Build an optimized application image

### 🔴 [Lesson 3: Working with Red Hat Universal Base Images](lessons/03-red-hat-ubi.md)
*"Enterprise-grade base images for production"*
- Introduction to Red Hat UBI
- Security and compliance benefits
- Building RHEL-compatible images
- **Lab**: Create production-ready images with UBI

### ⚡ [Lesson 4: Image Optimization and Best Practices](lessons/04-optimization-best-practices.md)
*"Making your images lean, fast, and secure"*
- Reducing image size
- Security best practices
- Layer caching strategies
- **Lab**: Optimize existing images

### 🚀 [Lesson 5: Publishing and Sharing Images](lessons/05-publishing-images.md)
*"Sharing your creations with the world"*
- Working with Docker registries
- Tagging and versioning strategies
- Publishing to Docker Hub
- **Lab**: Publish your own image

## 🎮 Module Challenge: "Build a Complete Web Application"

Create a complete web application with:
- Custom application code
- Optimized Dockerfile
- Multi-stage build process
- Security best practices
- Published to a registry

This challenge will test your ability to create production-ready container images.

## 🏆 Achievement Unlocked

Complete this module to earn your **"Dockerfile Developer"** badge! 🏗️

## 🤔 Discussion Topics

After completing the labs, consider these questions:
1. How does building custom images change your deployment strategy?
2. What are the security implications of creating your own images?
3. How do you balance image size vs functionality?
4. When would you use multi-stage builds vs single-stage builds?

## 📖 Quick Reference

### Essential Dockerfile Instructions
```dockerfile
FROM image:tag              # Base image
RUN command                 # Execute command during build
COPY source dest            # Copy files from host to image
ADD source dest             # Copy files (with additional features)
WORKDIR /path              # Set working directory
EXPOSE port                # Document exposed ports
ENV KEY=value              # Set environment variables
CMD ["command"]            # Default command to run
ENTRYPOINT ["command"]     # Command that always runs
USER username              # Set user for subsequent instructions
VOLUME ["/path"]           # Create mount point
LABEL key=value            # Add metadata to image
```

### Build Commands
```bash
docker build .                    # Build from current directory
docker build -t name:tag .        # Build with tag
docker build -f Dockerfile.prod . # Use specific Dockerfile
docker build --no-cache .         # Build without cache
docker build --target stage .     # Build specific stage (multi-stage)
```

### Image Management
```bash
docker images                     # List local images
docker tag source:tag target:tag  # Tag an image
docker push image:tag             # Push to registry
docker pull image:tag             # Pull from registry
docker rmi image:tag              # Remove image
docker history image:tag          # Show image layers
```

## 🔍 Image Building Use Cases

### Custom Web Applications
- Package your web app with its dependencies
- Include configuration files
- Set up proper user permissions
- Optimize for production deployment

### Development Environments
- Create consistent development environments
- Include all necessary tools and dependencies
- Share with team members
- Version control your environment

### Legacy Application Modernization
- Containerize existing applications
- Maintain compatibility while adding container benefits
- Gradual migration to cloud-native architectures

### Microservices Architecture
- Build lightweight, single-purpose images
- Optimize for fast startup and small size
- Include only necessary dependencies
- Enable independent scaling and deployment

## 🚀 Ready to Start?

Head over to [Lesson 1: Introduction to Dockerfiles](lessons/01-dockerfile-basics.md) and let's start building your own container images!

Remember: Every Docker expert started by writing their first Dockerfile. You're about to join the ranks of container creators! 🏗️

---

## 🆘 Need Help?

- **Dockerfile not working?** Check the syntax and instruction order
- **Build failing?** Look at the error messages carefully - they're usually helpful
- **Image too large?** We'll cover optimization techniques in Lesson 4
- **Security concerns?** We'll address best practices throughout the module

## 🎯 Pro Tips

1. **Start simple** and gradually add complexity
2. **Use official base images** when possible
3. **Keep Dockerfiles readable** with comments
4. **Test builds frequently** during development
5. **Use .dockerignore** to exclude unnecessary files

*"Building Docker images is like cooking - start with good ingredients, follow the recipe, and don't be afraid to experiment!"* 👨‍🍳
