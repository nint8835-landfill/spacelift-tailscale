#!/bin/sh

echo "Starting tailscaled..."
tailscaled --tun=userspace-networking --outbound-http-proxy-listen=localhost:1054 --socks5-server=localhost:1055 --socket=/tmp/tailscaled.sock 2>~/tailscaled.log &

echo "Connecting to Tailscale..."
HOSTNAME="spacelift-$(cat /etc/hostname)"
tailscale --socket=/tmp/tailscaled.sock up --authkey ${TAILSCALE_AUTH_KEY} --hostname=${HOSTNAME} --accept-routes

echo "Configuring proxy..."
export ALL_PROXY=socks5h://localhost:1055/
export HTTP_PROXY=http://localhost:1054/
export HTTPS_PROXY=http://localhost:1054/
export http_proxy=http://localhost:1054/
export https_proxy=http://localhost:1054/
echo "Tailscale configured (hopefully)"
