#!/bin/bash

echo "🚀 Telegram RSS API - نصب خودکار"
echo "========================================="
echo ""

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# چک کردن root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ لطفاً با sudo اجرا کنید${NC}"
    echo "مثال: sudo bash setup.sh"
    exit 1
fi

# گرفتن یوزر اصلی (نه root)
ACTUAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -z "$ACTUAL_USER" ] || [ "$ACTUAL_USER" = "root" ]; then
    ACTUAL_USER="root"
fi
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo -e "${BLUE}👤 نصب برای کاربر: $ACTUAL_USER${NC}"
echo ""

# نصب Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Docker نصب نیست. در حال نصب...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    if [ "$ACTUAL_USER" != "root" ]; then
        usermod -aG docker $ACTUAL_USER
    fi
    echo -e "${GREEN}✅ Docker نصب شد${NC}"
else
    echo -e "${GREEN}✅ Docker از قبل نصب است${NC}"
fi

# نصب Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 در حال نصب Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose نصب شد${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📋 راهنمای دریافت اطلاعات تلگرام:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. به آدرس زیر بروید:"
echo -e "   ${GREEN}https://my.telegram.org${NC}"
echo ""
echo "2. با شماره تلگرام خود وارد شوید"
echo ""
echo "3. روی 'API development tools' کلیک کنید"
echo ""
echo "4. یک اپلیکیشن جدید بسازید (اسم دلخواه)"
echo ""
echo "5. دو مقدار زیر را یادداشت کنید:"
echo "   - api_id (یک عدد مثل: 12345678)"
echo "   - api_hash (یک رشته مثل: 0a1b2c3d...)"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "آیا اطلاعات API را دریافت کرده‌اید؟ (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}لطفاً ابتدا اطلاعات API را دریافت کنید و دوباره اجرا کنید.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}📝 لطفاً اطلاعات خود را وارد کنید:${NC}"
echo ""

read -p "API_ID: " api_id
read -p "API_HASH: " api_hash
read -p "شماره تلگرام (با کد کشور مثل +989123456789): " phone

# اعتبارسنجی ورودی‌ها
if [[ -z "$api_id" || -z "$api_hash" || -z "$phone" ]]; then
    echo -e "${RED}❌ همه فیلدها الزامی هستند!${NC}"
    exit 1
fi

# ساخت .env
cat > .env << EOF
API_ID=$api_id
API_HASH=$api_hash
PHONE=$phone
EOF

if [ "$ACTUAL_USER" != "root" ]; then
    chown $ACTUAL_USER:$ACTUAL_USER .env
fi
echo -e "${GREEN}✅ فایل .env ساخته شد${NC}"
echo ""

# Build کردن
echo -e "${YELLOW}🔨 در حال build کردن Docker image...${NC}"
if [ "$ACTUAL_USER" != "root" ]; then
    sudo -u $ACTUAL_USER docker-compose build
else
    docker-compose build
fi
echo ""

# لاگین تعاملی
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔐 حالا باید وارد اکانت تلگرام خود شوید${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "کد تایید به تلگرام شما ارسال می‌شود."
echo "اگر Two-Step Verification دارید، پسورد هم لازم است."
echo ""
read -p "آماده هستید؟ (Enter را بزنید) " 

# اجرای موقت برای login
echo ""
echo -e "${YELLOW}⏳ در انتظار کد تایید...${NC}"

# ساخت اسکریپت لاگین موقت
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
        print("\n✅ لاگین موفقیت‌آمیز بود!")
        me = await client.get_me()
        print(f"👤 شما به عنوان {me.first_name} وارد شدید\n")
        await client.disconnect()
        return True
    except Exception as e:
        print(f"\n❌ خطا: {e}\n")
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
    echo -e "${GREEN}✅ لاگین با موفقیت انجام شد!${NC}"
    echo ""
else
    echo -e "${RED}❌ خطا در لاگین! لطفاً دوباره تلاش کنید.${NC}"
    exit 1
fi

# اجرای دائمی
echo -e "${YELLOW}🚀 در حال راه‌اندازی سرویس...${NC}"
if [ "$ACTUAL_USER" != "root" ]; then
    sudo -u $ACTUAL_USER docker-compose up -d
else
    docker-compose up -d
fi

sleep 3

# نمایش وضعیت
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ نصب با موفقیت کامل شد!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# دریافت IP
SERVER_IP=$(hostname -I | awk '{print $1}')

echo "📡 API در آدرس‌های زیر در دسترس است:"
echo ""
echo "   🌐 Local:    http://localhost:8000"
echo "   🌐 Network:  http://$SERVER_IP:8000"
echo ""
echo "📖 مستندات API:"
echo "   http://localhost:8000/docs"
echo "   http://$SERVER_IP:8000/docs"
echo ""
echo "🧪 تست سریع:"
echo "   curl http://localhost:8000/health"
echo ""
echo "📊 مشاهده لاگ‌ها:"
echo "   docker-compose logs -f"
echo ""
echo "🔄 مدیریت سرویس:"
echo "   docker-compose restart  # ری‌استارت"
echo "   docker-compose stop     # خاموش کردن"
echo "   docker-compose start    # روشن کردن"
echo "   docker-compose down     # حذف کامل"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$ACTUAL_USER" != "root" ]; then
    echo -e "${YELLOW}💡 نکته: برای استفاده بدون sudo، لاگ‌اوت و دوباره لاگین کنید${NC}"
    echo ""
fi

echo -e "${GREEN}🎉 از استفاده شما سپاسگزاریم!${NC}"
echo ""
