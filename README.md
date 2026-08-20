# Local Docker Services

Docker Compose setup for local development services with centralized nginx gateway and Let's Encrypt SSL certificates.

## Services

- **nginx-gateway**: Reverse proxy on port 443 with SSL termination
- **proget**: Package management server
- **rancher**: Kubernetes management UI on port 3443
- **postgres**: PostgreSQL 16 database server on port 5432
- **keycloak**: Identity and access management (IdP) at `idp.intra.jbdesign.com.br`
- **qdrant**: Vector database at `qdrant.intra.jbdesign.com.br`

## SSL Certificates

All services use Let's Encrypt certificates stored at `/data/ssl/letsencrypt/live/jbdesign.com.br/`.

## cert-users Group

The `cert-users` group (`GLOBAL_CERTIFICATE_GROUP`) is used to manage access to SSL certificates. Users that need to handle or read SSL certificates should be added to this group.

### Adding a user to cert-users

```bash
usermod -aG cert-users <username>
```

After adding a user to the group, they need to log out and back in for the changes to take effect.

## Setup

Run the setup script as root:

```bash
sudo bash setup-local.sh
```

This will:
1. Load environment variables from `parms.env`
2. Generate nginx configuration from templates
3. Create required data directories
4. Start all services

## Environment Variables

Main configuration is in `parms.env`. Run `sudo bash setup-local.sh` to regenerate the `.env` file.

## Data Directory

All persistent data is stored under `/data/`:
- `/data/nginx/` - nginx configuration and logs
- `/data/proget/` - ProGet packages, database, and backups
- `/data/rancher/` - Rancher state
- `/data/postgres/` - PostgreSQL database files
- `/data/keycloak/` - Keycloak data
- `/data/qdrant/` - Qdrant vector database storage
- `/data/ssl/` - Let's Encrypt certificates
