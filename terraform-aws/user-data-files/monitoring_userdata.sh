#!/bin/bash
# Update system packages
yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Create a directory for Prometheus and Grafana
mkdir -p /home/ec2-user/monitoring/prometheus /home/ec2-user/monitoring/grafana

# Create docker-compose.yml for monitoring services (Prometheus + Grafana)
cat <<EOF > /home/ec2-user/monitoring/docker-compose.yml
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus:/etc/prometheus
    networks:
      - monitoring-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    networks:
      - monitoring-network
    restart: always

networks:
  monitoring-network:
    driver: bridge
EOF

# Start Prometheus and Grafana containers
sudo docker-compose -f /home/ec2-user/monitoring/docker-compose.yml up -d
