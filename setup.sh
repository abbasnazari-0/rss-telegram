#!/bin/bash

echo "🚀 Telegram RSS API - Automated Installer"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: Please run as root${NC}"
    echo "Usage: sudo bash setup.sh"
    exit 1
fi

# Get actual user (not root)
ACTUAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -z "$ACTUAL_USER" ] || [ "$ACTUAL_USER" = "root" ]; then
    ACTUAL_USER="root"
fi
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo -e "${BLUE}Installing for user: $ACTUAL_USER${NC}"
echo ""

# Install Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found. Installing...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    if [ "$ACTUAL_USER" != "root" ]; then
        usermod -aG docker $ACTUAL_USER
    fi
    echo -e "${GREEN}Docker installed successfully${NC}"
else
    echo -e "${GREEN}Docker is already installed${NC}"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Installing Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}How to get Telegram API credentials:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Go to: ${GREEN}https://my.telegram.org${NC}"
echo ""
echo "2. Login with your phone number"
echo ""
echo "3. Click on 'API development tools'"
echo ""
echo "4. Create a new application (any name)"
echo ""
echo "5. Note down these two values:"
echo "   - api_id (a number like: 12345678)"
echo "   - api_hash (a string like: 0a1b2c3d...)"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Have you obtained API credentials? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please get your API credentials first and run again.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Please enter your information:${NC}"
echo ""

read -p "API_ID: " api_id
read -p "API_HASH: " api_hash
read -p "Phone number (with country code like +989123456789): " phone

# Validate inputs
if [[ -z "$api_id" || -z "$api_hash" || -z "$phone" ]]; then
    echo -e "${RED}Error: All fields are required!${NC}"
    exit 1
fi

# Create .env file
cat > .env << EOF
API_ID=$api_id
API_HASH=$api_hash
PHONE=$phone
EOF

if [ "$ACTUAL_USER" != "root" ]; then
    chown $ACTUAL_USER:$ACTUAL_USER .env
fi
echo -e "${GREEN}.env file created successfully${NC}"
echo ""

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
if [ "$ACTUAL_USER" != "root" ]; then
    sudo -u $ACTUAL_USER docker-compose build
else
    docker-compose build
fi
echo ""

# Interactive login
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Now you need to login to your Telegram account${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "A verification code will be sent to your Telegram."
echo "If you have Two-Step Verification, password is also required."
echo ""
read -p "Ready? (Press Enter to continue) " 

# Temporary login script
echo ""
echo -e "${YELLOW}Waiting for verification code...${NC}"

cat > /tmp/telegram_login.py << 'PYEOF'
import asyncio
from telethon import TelegramClient
import os
import sys

API_ID = int(os.getenv('API_ID'))
API_HASH = os.getenv('API_HASH')
PHONE = os.getenv('PHONE')

async def login():
    try:
        client = TelegramClient('session_name', API_ID, API_HASH)
        await client.start(phone=PHONE)
        print("\n✅ Login successful!")
        me = await client.get_me()
        print(f"👤 Logged in as: {me.first_name}\n")
        await client.disconnect()
        return True
    except Exception as e:
        print(f"\n❌ Error: {e}\n")
        return False

result = asyncio.run(login())
sys.exit(0 if result else 1)
PYEOF

if [ "$ACTUAL_USER" != "root" ]; then
    sudo -u $ACTUAL_USER docker-compose run --rm telegram-rss python3 /tmp/telegram_login.py
else
    docker-compose run --rm telegram-rss python3 /tmp/telegram_login.py
fi

LOGIN_RESULT=$?
rm -f /tmp/telegram_login.py

if [ $LOGIN_RESULT -eq 0 ]; then
    echo -e "${GREEN}Login completed successfully!${NC}"
    echo ""
else
    echo -e "${RED}Login failed! Please try again.${NC}"
    exit 1
fi

# Start service
echo -e "${YELLOW}Starting service...${NC}"
if [ "$ACTUAL_USER" != "root" ]; then
    sudo -u $ACTUAL_USER docker-compose up -d
else
    docker-compose up -d
fi

sleep 3

# Show status
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation completed successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "📡 API is available at:"
echo ""
echo "   🌐 Local:    http://localhost:8000"
echo "   🌐 Network:  http://$SERVER_IP:8000"
echo ""
echo "📖 API Documentation:"
echo "   http://localhost:8000/docs"
echo "   http://$SERVER_IP:8000/docs"
echo ""
echo "🧪 Quick test:"
echo "   curl http://localhost:8000/health"
echo ""
echo "📊 View logs:"
echo "   docker-compose logs -f"
echo ""
echo "🔄 Service management:"
echo "   docker-compose restart  # Restart"
echo "   docker-compose stop     # Stop"
echo "   docker-compose start    # Start"
echo "   docker-compose down     # Remove completely"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$ACTUAL_USER" != "root" ]; then
    echo -e "${YELLOW}💡 Note: For using docker without sudo, logout and login again${NC}"
    echo ""
fi

echo -e "${GREEN}🎉 Thank you for using Telegram RSS API!${NC}"
echo ""
