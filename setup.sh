#!/bin/bash

# رنگ‌ها
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# بررسی دسترسی روت
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Please run with sudo: sudo ./setup.sh${NC}"
  exit
fi

# دریافت نام کاربری واقعی (کسی که sudo زده)
REAL_USER=$SUDO_USER
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
WORK_DIR=$(pwd)
SERVICE_NAME="telegram-rss"

echo -e "${BLUE}=== Telegram RSS Setup & Service Installer ===${NC}"

# 1. نصب پکیج‌های سیستمی
echo -e "${GREEN}[1/5] Installing system dependencies...${NC}"
apt-get update -qq
apt-get install -y python3-venv python3-pip -qq

# 2. ساخت محیط مجازی پایتون
echo -e "${GREEN}[2/5] Setting up Python environment...${NC}"
# اجرای دستورات با دسترسی یوزر معمولی (نه روت) برای جلوگیری از مشکلات پرمیشن
sudo -u $REAL_USER python3 -m venv venv
sudo -u $REAL_USER ./venv/bin/pip install --upgrade pip
sudo -u $REAL_USER ./venv/bin/pip install -r requirements.txt

# 3. تنظیم فایل .env
echo -e "${GREEN}[3/5] Configuring credentials...${NC}"
if [ ! -f ".env" ]; then
    echo "Please enter your Telegram credentials:"
    read -p "Enter API ID: " api_id
    read -p "Enter API HASH: " api_hash
    read -p "Enter Phone Number (e.g., +98912...): " phone
    
    echo "API_ID=$api_id" > .env
    echo "API_HASH=$api_hash" >> .env
    echo "PHONE=$phone" >> .env
    chown $REAL_USER:$REAL_USER .env
else
    echo "✅ .env file already exists."
fi

# 4. اجرای دستی برای لاگین (بخش مهم)
echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}⚠️  LOGIN REQUIRED ⚠️${NC}"
echo -e "We will now run the script manually so you can login to Telegram."
echo -e "1. Look at the terminal to enter the login code."
echo -e "2. Once you see '${GREEN}✅ کلاینت تلگرام متصل شد${NC}', press ${RED}Ctrl+C${NC} to stop the app."
echo -e "${YELLOW}==============================================${NC}"
read -p "Press Enter to start login process..."

# اجرا با یوزر اصلی
sudo -u $REAL_USER ./venv/bin/python main.py

echo -e "\n${GREEN}✅ Login process finished. Proceeding to service creation...${NC}"

# 5. ساخت سرویس Systemd
echo -e "${GREEN}[5/5] Creating and starting systemd service...${NC}"
cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=Telegram RSS Generator API
After=network.target

[Service]
User=$REAL_USER
Group=$REAL_USER
WorkingDirectory=$WORK_DIR
Environment="PATH=$WORK_DIR/venv/bin"
# استفاده از uvicorn برای اجرای حرفه‌ای
ExecStart=$WORK_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# فعال‌سازی سرویس
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl restart $SERVICE_NAME

echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}✅ INSTALLATION COMPLETE!${NC}"
echo -e "Service Status: ${BLUE}sudo systemctl status $SERVICE_NAME${NC}"
echo -e "View Logs:      ${BLUE}sudo journalctl -u $SERVICE_NAME -f${NC}"
echo -e "App URL:        http://localhost:8000"