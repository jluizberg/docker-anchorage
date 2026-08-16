# Standard proxy headers
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-Port 443;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

# Timeouts (adjust as needed)
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s;
keepalive_timeout 60s;

# Buffer settings
proxy_buffering off;
proxy_http_version 1.1;
