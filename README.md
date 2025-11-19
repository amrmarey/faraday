# 🔒 Faraday Security Platform - Docker Deployment

<div align="center">

![Faraday](https://img.shields.io/badge/Faraday-Security%20Platform-blue?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Enterprise-grade Docker Compose deployment for Faraday Security Platform**

[Features](#features) • [Quick Start](#quick-start) • [Configuration](#configuration) • [Architecture](#architecture) • [Security](#security)

</div>

---

## 📋 Overview

This repository provides a production-ready Docker Compose setup for deploying [Faraday](https://github.com/infobyte/faraday), an open-source vulnerability management platform. It includes all necessary services with proper networking, security hardening, health checks, and resource management.

### What is Faraday?

Faraday is a collaborative penetration testing and vulnerability management platform that helps security teams organize, analyze, and manage security assessments. It aggregates and normalizes data from popular security tools, making it easier to track and remediate vulnerabilities.

---

## ✨ Features

- **🐳 Complete Docker Stack**: PostgreSQL, Redis, Faraday app, and Nginx reverse proxy
- **🔐 HTTPS by Default**: Automated self-signed SSL certificate generation
- **🏗️ Production-Ready**: Health checks, resource limits, and automatic restarts
- **🔄 Scalable**: Pre-configured for horizontal scaling with multiple replicas
- **🌐 Network Segregation**: Isolated frontend and backend networks for enhanced security
- **📊 Monitoring**: Built-in health checks for all services
- **⚡ High Performance**: Redis caching and optimized PostgreSQL configuration

---

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.0+
- Minimum 4GB RAM
- 20GB free disk space

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/amrmarey/faraday.git
   cd faraday
   ```

2. **Configure environment variables**
   ```bash
   cp example.env .env
   # Edit .env with your preferred settings
   nano .env
   ```

3. **Launch the stack**
   ```bash
   docker-compose up -d
   ```

4. **Verify deployment**
   ```bash
   docker-compose ps
   docker-compose logs -f faraday
   ```

5. **Access Faraday**
   - HTTPS: `https://localhost` or `https://your-domain.com`
   - HTTP: `http://localhost` (redirects to HTTPS)
   - Default credentials: Check Faraday documentation

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file from `example.env` and customize:

```bash
# Database Configuration
POSTGRES_USER=faraday
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=faraday

# Redis Configuration
REDIS_URL=redis://redis:6379/0

# Faraday Configuration
FARADAY_SERVER_SECRET_KEY=your_random_secret_key_here

# Nginx Configuration
DOMAIN_NAME=faraday.local
```

> ⚠️ **Security Note**: Always change default passwords and generate strong secret keys for production deployments.

### SSL Certificates

#### Self-Signed Certificates (Default)

The setup automatically generates self-signed SSL certificates on first run. Perfect for development and testing.

#### Custom SSL Certificates

For production, replace self-signed certificates with trusted ones:

```bash
# Place your certificates in the nginx/certs directory
cp your-cert.crt nginx/certs/faraday.crt
cp your-key.key nginx/certs/faraday.key

# Restart nginx
docker-compose restart nginx
```

#### Let's Encrypt (Recommended for Production)

For automated SSL with Let's Encrypt, modify the nginx service or use a reverse proxy like Traefik or Caddy.

### Scaling

To scale the Faraday application:

```bash
docker-compose up -d --scale faraday=4
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Internet/Users                     │
└──────────────────────┬──────────────────────────────┘
                       │
                       │ HTTPS/HTTP
                       │
         ┌─────────────▼─────────────┐
         │    Nginx (Reverse Proxy)   │
         │   - SSL Termination        │
         │   - Load Balancing         │
         └─────────────┬──────────────┘
                       │ Frontend Network
         ┌─────────────▼─────────────┐
         │   Faraday App (x2 Replicas)│
         │   - API Server             │
         │   - Web Interface          │
         └─────────────┬──────────────┘
                       │ Backend Network
         ┌─────────────▼──────┬───────────┐
         │                    │           │
    ┌────▼─────┐      ┌───────▼───────┐   │
    │PostgreSQL│      │     Redis     │   │
    │    DB    │      │    Cache      │   │
    └──────────┘      └───────────────┘   │
```

### Service Details

| Service | Container | Ports | Resources | Purpose |
|---------|-----------|-------|-----------|---------|
| **Nginx** | faraday_nginx | 80, 443 | 1 CPU, 512MB | Reverse proxy, SSL termination |
| **Faraday** | faraday_app | Internal | 2 CPU, 2GB | Main application (2 replicas) |
| **PostgreSQL** | faraday_postgres | Internal | 1 CPU, 1GB | Primary database |
| **Redis** | faraday_redis | Internal | 0.5 CPU, 512MB | Caching & job queue |

---

## 🔐 Security

### Built-in Security Features

- ✅ Network segregation (frontend/backend isolation)
- ✅ HTTPS enabled by default
- ✅ Sensitive data in environment variables (not in docker-compose.yml)
- ✅ Health checks to detect compromised services
- ✅ Resource limits to prevent DoS
- ✅ Read-only nginx configuration mount

### Security Best Practices

1. **Change Default Credentials**
   ```bash
   # Update all default passwords in .env
   POSTGRES_PASSWORD=$(openssl rand -base64 32)
   FARADAY_SERVER_SECRET_KEY=$(openssl rand -hex 32)
   ```

2. **Use Trusted SSL Certificates**
   - Replace self-signed certificates with CA-signed certificates
   - Use Let's Encrypt for free, automated SSL

3. **Network Firewall**
   ```bash
   # Allow only necessary ports
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw enable
   ```

4. **Regular Updates**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

5. **Database Backups**
   ```bash
   # Backup PostgreSQL database
   docker exec faraday_postgres pg_dump -U faraday faraday > backup_$(date +%Y%m%d).sql
   ```

---

## 🛠️ Management

### Common Commands

```bash
# View logs
docker-compose logs -f [service_name]

# Restart a service
docker-compose restart [service_name]

# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ Data loss!)
docker-compose down -v

# View resource usage
docker stats

# Execute commands in container
docker exec -it faraday_app bash
```

### Health Monitoring

Check service health status:

```bash
docker-compose ps
```

All services should show "healthy" status. If not:

```bash
# Check specific service logs
docker-compose logs [service_name]

# Restart unhealthy service
docker-compose restart [service_name]
```

---

## 🐛 Troubleshooting

### Faraday won't start

**Issue**: Container keeps restarting

**Solution**:
```bash
# Check logs for errors
docker-compose logs faraday

# Verify database connectivity
docker exec faraday_app curl -f http://postgres:5432

# Reset and restart
docker-compose down && docker-compose up -d
```

### Cannot access via HTTPS

**Issue**: SSL certificate errors

**Solution**:
```bash
# Verify certificate exists
docker exec faraday_nginx ls -la /etc/nginx/certs/

# Regenerate certificate
docker-compose down
docker volume rm faraday_nginx_certs
docker-compose up -d
```

### Database connection errors

**Issue**: Faraday can't connect to PostgreSQL

**Solution**:
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Verify credentials match in .env and docker-compose.yml
# Restart stack
docker-compose restart
```

### Port already in use

**Issue**: Ports 80/443 already bound

**Solution**:
```bash
# Find process using port
sudo lsof -i :80
sudo lsof -i :443

# Stop conflicting service or change ports in docker-compose.yml
```

---

## 📚 Additional Resources

- [Faraday Official Documentation](https://docs.faradaysec.com/)
- [Faraday GitHub Repository](https://github.com/infobyte/faraday)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⭐ Support

If you find this project helpful, please consider giving it a star ⭐

For issues and questions:
- Open an [issue](https://github.com/amrmarey/faraday/issues)
- Contact: [Your contact information]

---

<div align="center">

**Built with ❤️ for the security community**

[Report Bug](https://github.com/amrmarey/faraday/issues) · [Request Feature](https://github.com/amrmarey/faraday/issues)

</div>