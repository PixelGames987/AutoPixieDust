#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

USERNAME=$(whoami)
USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

echo -e "${BLUE}[*] Updating and Upgrading OS...${NC}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}[*] System updated and upgraded successfully.${NC}\n"

echo -e "${BLUE}[*] Disabling Power Management for wlan0 and wlan1...${NC}"

SERVICE_FILE_PM0="/etc/systemd/system/disable-wlan0-pm.service"
SERVICE_FILE_PM1="/etc/systemd/system/disable-wlan1-pm.service"

sudo tee "$SERVICE_FILE_PM0" > /dev/null << EOF
[Unit]
Description=Disable Power Management for wlan0
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/iw dev wlan0 set power_save off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo tee "$SERVICE_FILE_PM1" > /dev/null << EOF
[Unit]
Description=Disable Power Management for wlan1
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/iw dev wlan1 set power_save off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable disable-wlan0-pm.service
sudo systemctl enable disable-wlan1-pm.service
sudo systemctl start disable-wlan0-pm.service
sudo systemctl start disable-wlan1-pm.service

echo -e "${BLUE}[*] Installing required packages...${NC}"
PACKAGES="python3 wpasupplicant iw wget pixiewps"
sudo apt install -y $PACKAGES
echo -e "${GREEN}[*] Packages installed successfully.${NC}\n"

echo -e "${BLUE}[*] Creating systemd service for auto-pixie.py...${NC}"

PYTHON_SCRIPT_PATH="${USER_HOME}/auto-pixie.py"
SERVICE_FILE_PIXIE="/etc/systemd/system/auto-pixie.service"

sudo tee "$SERVICE_FILE_PIXIE" > /dev/null << EOF
[Unit]
Description=Auto Pixie Attack Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 ${PYTHON_SCRIPT_PATH}
WorkingDirectory=${USER_HOME}
Restart=always
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable auto-pixie.service
sudo systemctl start auto-pixie.service

echo -e "${BLUE}\nCloning OneShot-Extended...${NC}"
git clone https://github.com/chickendrop89/OneShot-Extended ose

echo -e "${BLUE}\n[*] Setup finished.${NC}"
