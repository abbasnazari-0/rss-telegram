#!/bin/bash

# Telegram RSS Generator - Setup Script
# This script will install dependencies, configure environment, and setup systemd service

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Telegram RSS Generator - Setup${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if running as root
IS_ROOT=0
if [ "$EUID" -eq 0 ]; then 
    IS_ROOT=1
    echo -e "${YELLOW}⚠️  Running as root user${NC}"
    echo -e "${YELLOW}Installing as system-wide service...${NC}\n"
else
    echo -e "${GREEN}✅ Running as normal user${NC}\n"
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check Python installation
echo -e "${BLUE}[1/7]${NC} Checking Python installation..."
if ! command_exists python3; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo -e "${YELLOW}Please install Python 3.8 or higher${NC}\n"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo -e "${GREEN}✅ Python $PYTHON_VERSION found${NC}\n"

# Step 2: Create virtual environment
echo -e "${BLUE}[2/7]${NC} Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}\n"
else
    echo -e "${YELLOW}⚠️  Virtual environment already exists${NC}\n"
fi

# Step 3: Install dependencies
echo -e "${BLUE}[3/7]${NC} Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt
echo -e "${GREEN}✅ Dependencies installed${NC}\n"

# Step 4: Setup environment file
echo -e "${BLUE}[4/7]${NC} Setting up environment configuration..."
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    cp .env.example .env
    
    echo -e "\n${YELLOW}Please enter your Telegram API credentials:${NC}"
    echo -e "${BLUE}(Get them from: https://my.telegram.org/apps)${NC}\n"
    
    read -p "API_ID: " api_id
    read -p "API_HASH: " api_hash
    read -p "PHONE (e.g., +989123456789): " phone
    read -p "BASE_URL (e.g., http://your-server.com:8000): " base_url
    
    # Update .env file
    sed -i.bak "s|API_ID=.*|API_ID=$api_id|g" .env
    sed -i.bak "s|API_HASH=.*|API_HASH=$api_hash|g" .env
    sed -i.bak "s|PHONE=.*|PHONE=$phone|g" .env
    sed -i.bak "s|BASE_URL=.*|BASE_URL=$base_url|g" .env
    rm .env.bak
    
    echo -e "${GREEN}✅ Environment file configured${NC}\n"
else
    echo -e "${GREEN}✅ .env file already exists${NC}\n"
fi

# Step 5: Login to Telegram
echo -e "${BLUE}[5/7]${NC} Telegram authentication..."
if [ ! -f "session_name.session" ]; then
    echo -e "${YELLOW}⚠️  No session file found. Starting login process...${NC}\n"
    python3 login.py
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Successfully logged in to Telegram${NC}\n"
    else
        echo -e "\n${RED}❌ Login failed${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Session file already exists${NC}\n"
fi

# Step 6: Setup systemd service
echo -e "${BLUE}[6/7]${NC} Setting up systemd service..."

SERVICE_FILE="rss-telegram.service"

if [ "$IS_ROOT" -eq 1 ]; then
    # System-wide service configuration
    SYSTEMD_DIR="/etc/systemd/system"
    
    # Create service file for root
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Telegram RSS Generator Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR
Environment="PATH=$SCRIPT_DIR/venv/bin"
ExecStart=$SCRIPT_DIR/venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

else
    # User service configuration
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"

    # Create service file for user
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Telegram RSS Generator Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$SCRIPT_DIR
Environment="PATH=$SCRIPT_DIR/venv/bin"
ExecStart=$SCRIPT_DIR/venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
fi

# Copy service file to systemd directory
cp "$SERVICE_FILE" "$SYSTEMD_DIR/"
echo -e "${GREEN}✅ Service file created at $SYSTEMD_DIR/$SERVICE_FILE${NC}"

# Reload systemd
if [ "$IS_ROOT" -eq 1 ]; then
    systemctl daemon-reload
else
    systemctl --user daemon-reload
fi
echo -e "${GREEN}✅ Systemd reloaded${NC}\n"

# Step 7: Service management
echo -e "${BLUE}[7/7]${NC} Starting service..."

if [ "$IS_ROOT" -eq 1 ]; then
    systemctl enable rss-telegram.service
    systemctl start rss-telegram.service
    
    if systemctl is-active --quiet rss-telegram.service; then
        echo -e "${GREEN}✅ Service started successfully${NC}\n"
    else
        echo -e "${RED}❌ Service failed to start${NC}"
        echo -e "${YELLOW}Check logs with: journalctl -u rss-telegram.service -f${NC}\n"
        exit 1
    fi
else
    systemctl --user enable rss-telegram.service
    systemctl --user start rss-telegram.service
    
    if systemctl --user is-active --quiet rss-telegram.service; then
        echo -e "${GREEN}✅ Service started successfully${NC}\n"
    else
        echo -e "${RED}❌ Service failed to start${NC}"
        echo -e "${YELLOW}Check logs with: journalctl --user -u rss-telegram.service -f${NC}\n"
        exit 1
    fi
fi

# Final summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Service Commands:${NC}"
if [ "$IS_ROOT" -eq 1 ]; then
    echo -e "  Start:   ${YELLOW}systemctl start rss-telegram.service${NC}"
    echo -e "  Stop:    ${YELLOW}systemctl stop rss-telegram.service${NC}"
    echo -e "  Restart: ${YELLOW}systemctl restart rss-telegram.service${NC}"
    echo -e "  Status:  ${YELLOW}systemctl status rss-telegram.service${NC}"
    echo -e "  Logs:    ${YELLOW}journalctl -u rss-telegram.service -f${NC}\n"
else
    echo -e "  Start:   ${YELLOW}systemctl --user start rss-telegram.service${NC}"
    echo -e "  Stop:    ${YELLOW}systemctl --user stop rss-telegram.service${NC}"
    echo -e "  Restart: ${YELLOW}systemctl --user restart rss-telegram.service${NC}"
    echo -e "  Status:  ${YELLOW}systemctl --user status rss-telegram.service${NC}"
    echo -e "  Logs:    ${YELLOW}journalctl --user -u rss-telegram.service -f${NC}\n"
fi

echo -e "${BLUE}API Endpoints:${NC}"
echo -e "  Health:  ${YELLOW}curl http://localhost:8000/health${NC}"
echo -e "  RSS:     ${YELLOW}curl http://localhost:8000/rss?channel=@durov&limit=20${NC}"
echo -e "  JSON:    ${YELLOW}curl http://localhost:8000/json?channel=@durov&limit=10${NC}"
echo -e "  Docs:    ${YELLOW}http://localhost:8000/docs${NC}\n"

echo -e "${GREEN}🚀 Your RSS service is now running!${NC}\n"
