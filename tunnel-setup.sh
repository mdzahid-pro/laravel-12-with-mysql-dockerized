#!/bin/bash

# Create a .env file in the project root to store your Cloudflare tunnel token
echo "CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiODYwMmIwMWFjNzFjMDI4MDY3OGUwMDU5MGFiMmRjZTQiLCJ0IjoiZGViZGNkOTMtZDBlMS00YTMwLWJhYjItMTM0MDE4ZDlkYjRjIiwicyI6Ik1UaGlaVGswTXpBdFptWTJaQzAwWTJRNUxUa3dNamt0TnpOaU16YzFOVFJtT0RkaSJ9" > .env

# Instructions for setting up Cloudflare tunnel
echo "===== Cloudflare Tunnel Setup Instructions ====="
echo "1. Replace 'your-cloudflare-tunnel-token' in the .env file with your actual Cloudflare tunnel token"
echo "2. Make sure the .env file is in the same directory as your docker-compose.yml file"
echo "3. Create a tunnel in the Cloudflare Zero Trust dashboard:"
echo "   a. Go to https://dash.teams.cloudflare.com/"
echo "   b. Navigate to Access > Tunnels"
echo "   c. Click 'Create a tunnel'"
echo "   d. Give it a name (e.g., 'laravel-app')"
echo "   e. Copy the token provided and paste it in the .env file"
echo "   f. For Public Hostname, configure:"
echo "      - Domain: laravel-app.devzahid.com"
echo "      - Service: HTTP"
echo "      - URL: http://nginx:80"
echo "4. Then start your Docker containers with docker-compose up -d"
echo "================================================="