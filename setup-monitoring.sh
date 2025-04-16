#!/usr/bin/env bash
#cloud-boothook
set -euo pipefail
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

### === VARIABLES — edit before launch ===
PROM_VER="2.47.1"
NODE_EXP_VER="1.6.1"
JENKINS_HOST="jenkins.example.com"
JENKINS_PORT="8080"
PROM_USER="prometheus"
NODE_USER="node_exporter"
PROM_DATA_DIR="/data"
PROM_CONF_DIR="/etc/prometheus"
PROM_BIN_DIR="/usr/local/bin"
SYSTEMD_DIR="/etc/systemd/system"
GRAFANA_DEB="https://packages.grafana.com/oss/deb"

### === HELPER ===
yum update -y || apt-get update -y  # support Amazon Linux (yum) or Ubuntu (apt)

install_prometheus() {
  echo "--- Installing Prometheus ${PROM_VER} ---"
  id -u $PROM_USER &>/dev/null || useradd --system --no-create-home --shell /bin/false $PROM_USER

  wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROM_VER}/prometheus-${PROM_VER}.linux-amd64.tar.gz"
  tar -xzf prometheus-${PROM_VER}.linux-amd64.tar.gz

  mkdir -p ${PROM_DATA_DIR} ${PROM_CONF_DIR}
  mv prometheus-${PROM_VER}.linux-amd64/prometheus ${PROM_BIN_DIR}/
  mv prometheus-${PROM_VER}.linux-amd64/promtool ${PROM_BIN_DIR}/
  mv prometheus-${PROM_VER}.linux-amd64/consoles ${PROM_CONF_DIR}/
  mv prometheus-${PROM_VER}.linux-amd64/console_libraries ${PROM_CONF_DIR}/
  mv prometheus-${PROM_VER}.linux-amd64/prometheus.yml ${PROM_CONF_DIR}/prometheus.yml

  chown -R ${PROM_USER}:${PROM_USER} ${PROM_CONF_DIR} ${PROM_DATA_DIR}

  cat > ${SYSTEMD_DIR}/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=${PROM_USER}
Group=${PROM_USER}
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=${PROM_BIN_DIR}/prometheus \\
  --config.file=${PROM_CONF_DIR}/prometheus.yml \\
  --storage.tsdb.path=${PROM_DATA_DIR} \\
  --web.console.templates=${PROM_CONF_DIR}/consoles \\
  --web.console.libraries=${PROM_CONF_DIR}/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable prometheus
  systemctl start prometheus
  echo "Prometheus up on port 9090."
}

install_node_exporter() {
  echo "--- Installing Node Exporter ${NODE_EXP_VER} ---"
  id -u $NODE_USER &>/dev/null || useradd --system --no-create-home --shell /bin/false $NODE_USER

  wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXP_VER}/node_exporter-${NODE_EXP_VER}.linux-amd64.tar.gz"
  tar -xzf node_exporter-${NODE_EXP_VER}.linux-amd64.tar.gz
  mv node_exporter-${NODE_EXP_VER}.linux-amd64/node_exporter /usr/local/bin/
  rm -rf node_exporter-${NODE_EXP_VER}.linux-amd64*

  cat > ${SYSTEMD_DIR}/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=${NODE_USER}
Group=${NODE_USER}
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable node_exporter
  systemctl start node_exporter
  echo "Node Exporter up on port 9100."
}

configure_prometheus_scrape() {
  echo "--- Configuring Prometheus ---"
  cat > ${PROM_CONF_DIR}/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['${JENKINS_HOST}:${JENKINS_PORT}']
EOF

  ${PROM_BIN_DIR}/promtool check config ${PROM_CONF_DIR}/prometheus.yml
  curl -s -X POST http://localhost:9090/-/reload || true
}

install_grafana() {
  echo "--- Installing Grafana ---"
  if command -v yum &>/dev/null; then
    yum install -y https://dl.grafana.com/oss/release/grafana-9.5.0-1.x86_64.rpm
  else
    apt-get install -y apt-transport-https software-properties-common wget
    wget -qO - https://packages.grafana.com/gpg.key | apt-key add -
    echo "deb ${GRAFANA_DEB} stable main" \
      | tee /etc/apt/sources.list.d/grafana.list
    apt-get update -y
    apt-get install -y grafana
  fi
  systemctl enable grafana-server
  systemctl start grafana-server
  echo "Grafana up on port 3000."
}

### === EXECUTION ===
install_prometheus
install_node_exporter
configure_prometheus_scrape
install_grafana

echo "=== Monitoring Stack Ready ==="
echo "Prometheus: http://\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):9090"
echo "Grafana:    http://\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):3000 (admin/admin)"
