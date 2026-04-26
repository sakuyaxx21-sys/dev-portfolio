#!/bin/bash
set -xe

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

docker run -d \
  --name dev-portfolio-app \
  -p 8000:80 \
  --restart unless-stopped \
  tiangolo/uvicorn-gunicorn-fastapi:python3.11