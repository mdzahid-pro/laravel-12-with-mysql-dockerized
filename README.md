# 🐳 Laravel Docker Development Environment

A complete Docker-based development environment for Laravel applications with PHP 8.4, MySQL, Redis, Memcached, and more.

## 📦 Services

This development stack includes:

- **Nginx** - Web server and reverse proxy
- **PHP 8.4** - PHP-FPM for running Laravel
- **Node.js** - For frontend assets compilation
- **MySQL** - Database server
- **PHPMyAdmin** - Database management UI
- **Redis** - In-memory data structure store
- **Memcached** - Distributed memory caching
- **Supervisor** - Process monitor for Laravel Horizon
- **MailHog** - Email testing tool
- **Cloudflare Tunnel** - Expose local environment to the internet (optional)

## 🚀 Getting Started

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Installation

1. Clone this repository:

```bash
git clone <repository-url>
cd <project-directory>
```

2. Run the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- Create necessary Docker configuration files
- Build Docker containers
- Install Laravel
- Configure environment variables
- Set up Laravel Horizon

3. Access your application:
    - Laravel app: http://localhost:8000
    - PHPMyAdmin: http://localhost:8080
    - MailHog: http://localhost:8025

## 🌐 Cloudflare Tunnel Setup (Optional)

To expose your local environment to the internet:

1. Run the tunnel setup script:

```bash
chmod +x tunnel-setup.sh
./tunnel-setup.sh
```

2. Follow the on-screen instructions to:
    - Create a tunnel in Cloudflare Zero Trust dashboard
    - Configure your tunnel token in `.env`
    - Map your domain to the local services

## 🧰 Docker Configuration

### Port Mappings

- Laravel application: `8000:80`
- PHPMyAdmin: `8080:80`
- MySQL: `3307:3306`
- Redis: `6380:6379`
- Memcached: `11211:11211`
- Node.js (Vite): `5173:5173`
- MailHog SMTP: `1025:1025`
- MailHog UI: `8025:8025`

### Volume Mounts

- Application code: `./src:/var/www/html`
- MySQL data: `mysql-data:/var/lib/mysql`
- Redis data: `redis-data:/data`

## 💻 Development Workflow

### Running Commands

Execute Laravel commands:

```bash
docker compose exec php php artisan <command>
```

Run Composer commands:

```bash
docker compose exec php composer <command>
```

Execute NPM commands:

```bash
docker compose exec node npm <command>
```

### Container Management

Start containers:

```bash
docker compose up -d
```

Stop containers:

```bash
docker compose down
```

View logs:

```bash
docker compose logs -f [service]
```

## 📋 Project Structure

```
.
├── docker/                # Docker configuration files
│   ├── nginx/             # Nginx configuration
│   ├── php/               # PHP configuration
│   ├── node/              # Node.js configuration
│   └── supervisor/        # Supervisor configuration
├── src/                   # Laravel application code
├── .env                   # Environment variables
├── docker-compose.yml     # Docker services configuration
├── setup.sh               # Setup script
├── tunnel-setup.sh        # Cloudflare tunnel setup script
└── README.md              # This file
```

## 🔧 Customization

### PHP Version

You can change the PHP version by modifying the `PHP_VERSION` argument in `docker-compose.yml`:

```yaml
php:
  build:
    context: ./docker/php
    args:
      PHP_VERSION: 8.4  # Change to your desired version
```

### Database Configuration

MySQL credentials are defined in `docker-compose.yml`:

```yaml
environment:
  MYSQL_DATABASE: laravel
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: laravel
  MYSQL_PASSWORD: laravel
```

## ⚠️ Security Notes

- This is a development environment and is not intended for production use
- The included `.env` file contains a sample Cloudflare tunnel token that should be replaced with your own
- Sensitive credentials in `docker-compose.yml` should be changed before exposing services to the internet

## 📚 Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)