# 📡 Telegram RSS Generator

<div dir="rtl">

یک سرویس قدرتمند و حرفه‌ای برای تبدیل کانال‌های تلگرام به RSS Feed با پشتیبانی کامل از رسانه‌ها

</div>

A powerful and professional service to convert Telegram channels into RSS feeds with full media support.

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com/)
[![Telethon](https://img.shields.io/badge/Telethon-1.33+-orange.svg)](https://docs.telethon.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features / امکانات

<div dir="rtl">

### 🎯 ویژگی‌های اصلی

- 📰 **تبدیل خودکار** کانال‌های تلگرام به RSS Feed
- 🖼️ **پشتیبانی کامل** از تصاویر و آلبوم‌ها
- 🔐 **سازگار با کانال‌های خصوصی** (Private Channels)
- ⚡ **API سریع و کارآمد** بر پایه FastAPI
- 🔄 **سرویس پایدار** با systemd
- 📦 **نصب آسان** با یک دستور
- 🌐 **پشتیبانی JSON** برای استفاده‌های مختلف
- 📊 **گروه‌بندی هوشمند** آلبوم‌های عکس
- 🚀 **مستندات خودکار** با Swagger UI

</div>

### 🎯 Key Features

- 📰 **Automatic conversion** of Telegram channels to RSS Feed
- 🖼️ **Full support** for images and albums
- 🔐 **Compatible with private channels**
- ⚡ **Fast and efficient API** based on FastAPI
- 🔄 **Persistent service** with systemd
- 📦 **Easy installation** with one command
- 🌐 **JSON support** for various uses
- 📊 **Smart grouping** of photo albums
- 🚀 **Automatic documentation** with Swagger UI

---

## 📋 Table of Contents

- [Requirements](#-requirements--پیش-نیازها)
- [Installation](#-installation--نصب)
- [Usage](#-usage--استفاده)
- [API Documentation](#-api-documentation--مستندات-api)
- [Service Management](#-service-management--مدیریت-سرویس)
- [Configuration](#-configuration--پیکربندی)
- [Examples](#-examples--مثال‌ها)
- [Troubleshooting](#-troubleshooting--عیب-یابی)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔧 Requirements / پیش‌نیازها

<div dir="rtl">

### سیستم مورد نیاز

- **Python 3.8 یا بالاتر**
- **Linux/macOS** (برای systemd روی لینوکس)
- **حساب تلگرام** و API Credentials

### دریافت API Credentials

1. به [my.telegram.org/apps](https://my.telegram.org/apps) بروید
2. با شماره تلگرام خود وارد شوید
3. یک اپلیکیشن جدید بسازید
4. `API_ID` و `API_HASH` را کپی کنید

</div>

### System Requirements

- **Python 3.8 or higher**
- **Linux/macOS** (for systemd on Linux)
- **Telegram account** and API Credentials

### Get API Credentials

1. Go to [my.telegram.org/apps](https://my.telegram.org/apps)
2. Login with your Telegram phone number
3. Create a new application
4. Copy `API_ID` and `API_HASH`

---

## 🚀 Installation / نصب

<div dir="rtl">

### نصب خودکار (توصیه می‌شود)

فقط کافیست یک دستور را اجرا کنید:

</div>

### Automatic Installation (Recommended)

Just run one command:

```bash
# Clone the repository
git clone https://github.com/abbasnazari-0/rss-telegram.git
cd rss-telegram

# Make setup script executable
chmod +x setup.sh

# Run setup (will ask for credentials)
./setup.sh
```

<div dir="rtl">

اسکریپت به صورت خودکار:
- محیط مجازی پایتون را می‌سازد
- وابستگی‌ها را نصب می‌کند
- مشخصات API را از شما می‌پرسد
- به تلگرام لاگین می‌کند
- سرویس systemd را راه‌اندازی می‌کند
- سرویس را شروع می‌کند

</div>

The script will automatically:
- Create Python virtual environment
- Install dependencies
- Ask for API credentials
- Login to Telegram
- Setup systemd service
- Start the service

---

## 💻 Usage / استفاده

<div dir="rtl">

### دریافت RSS Feed

</div>

### Get RSS Feed

```bash
# Public channel
curl "http://localhost:8000/rss?channel=@durov&limit=20"

# Private channel (you must be a member)
curl "http://localhost:8000/rss?channel=-1001234567890&limit=10"

# Private channel with invite link
curl "http://localhost:8000/rss?channel=https://t.me/+XXXXX&limit=15"
```

<div dir="rtl">

### دریافت JSON

</div>

### Get JSON

```bash
curl "http://localhost:8000/json?channel=@durov&limit=10"
```

<div dir="rtl">

### بررسی وضعیت سرویس

</div>

### Health Check

```bash
curl "http://localhost:8000/health"
```

---

## 📖 API Documentation / مستندات API

<div dir="rtl">

### Endpoints اصلی

</div>

### Main Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information |
| `/health` | GET | Service health check |
| `/rss` | GET | Get RSS feed |
| `/json` | GET | Get JSON data |
| `/download/{channel_id}/{msg_id}/{media_id}` | GET | Download media file |
| `/docs` | GET | Interactive API documentation |

<div dir="rtl">

### پارامترهای `/rss` و `/json`

</div>

### Parameters for `/rss` and `/json`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `channel` | string | ✅ Yes | Channel username (@channel), link, or ID |
| `limit` | integer | ❌ No | Number of posts (default: 50) |

<div dir="rtl">

### مثال‌های Channel

</div>

### Channel Examples

```bash
# Username
channel=@durov

# Public link
channel=https://t.me/durov

# Private channel ID (must be member)
channel=-1001234567890

# Private invite link
channel=https://t.me/+XXXXXXXXX
```

<div dir="rtl">

### مستندات تعاملی Swagger

بعد از راه‌اندازی سرویس، به آدرس زیر بروید:

</div>

### Interactive Swagger Documentation

After starting the service, go to:

```
http://localhost:8000/docs
```

---

## 🔄 Service Management / مدیریت سرویس

<div dir="rtl">

### دستورات سرویس

</div>

### Service Commands

```bash
# Start service / شروع سرویس
systemctl --user start rss-telegram.service

# Stop service / توقف سرویس
systemctl --user stop rss-telegram.service

# Restart service / ری‌استارت سرویس
systemctl --user restart rss-telegram.service

# Check status / بررسی وضعیت
systemctl --user status rss-telegram.service

# View logs / مشاهده لاگ‌ها
journalctl --user -u rss-telegram.service -f

# Enable auto-start / فعال‌سازی اجرای خودکار
systemctl --user enable rss-telegram.service

# Disable auto-start / غیرفعال‌سازی اجرای خودکار
systemctl --user disable rss-telegram.service
```

---

## ⚙️ Configuration / پیکربندی

<div dir="rtl">

### فایل `.env`

</div>

### `.env` File

```bash
# Telegram API Credentials
API_ID=your_api_id
API_HASH=your_api_hash
PHONE=+989123456789

# Server Configuration
BASE_URL=http://your-server.com:8000
HOST=0.0.0.0
PORT=8000

# Optional
SESSION_NAME=session_name
```

<div dir="rtl">

### تغییر پورت

برای تغییر پورت، فایل `setup.sh` را ویرایش کنید:

</div>

### Change Port

To change the port, edit `rss-telegram.service`:

```bash
nano ~/.config/systemd/user/rss-telegram.service
```

<div dir="rtl">

خط `ExecStart` را تغییر دهید:

</div>

Change the `ExecStart` line:

```ini
ExecStart=/path/to/venv/bin/python -m uvicorn main:app --host 0.0.0.0 --port YOUR_PORT
```

<div dir="rtl">

سپس سرویس را reload کنید:

</div>

Then reload the service:

```bash
systemctl --user daemon-reload
systemctl --user restart rss-telegram.service
```

---

## 📝 Examples / مثال‌ها

<div dir="rtl">

### استفاده در RSS Readers

می‌توانید URL های زیر را در RSS reader خود اضافه کنید:

</div>

### Use in RSS Readers

You can add these URLs to your RSS reader:

```
http://your-server.com:8000/rss?channel=@durov&limit=50
http://your-server.com:8000/rss?channel=-1001234567890&limit=20
```

<div dir="rtl">

### استفاده در برنامه‌نویسی

</div>

### Use in Programming

#### Python

```python
import requests

# Get RSS feed
response = requests.get('http://localhost:8000/rss', params={
    'channel': '@durov',
    'limit': 20
})
rss_content = response.text

# Get JSON data
response = requests.get('http://localhost:8000/json', params={
    'channel': '@durov',
    'limit': 10
})
data = response.json()

for message in data['messages']:
    print(f"Text: {message['text']}")
    print(f"Date: {message['date']}")
    print(f"Media count: {len(message['media'])}")
```

#### JavaScript

```javascript
// Get RSS feed
fetch('http://localhost:8000/rss?channel=@durov&limit=20')
  .then(response => response.text())
  .then(rss => console.log(rss));

// Get JSON data
fetch('http://localhost:8000/json?channel=@durov&limit=10')
  .then(response => response.json())
  .then(data => {
    data.messages.forEach(msg => {
      console.log(`Text: ${msg.text}`);
      console.log(`Date: ${msg.date}`);
      console.log(`Media: ${msg.media.length}`);
    });
  });
```

#### cURL

```bash
# Save RSS to file
curl "http://localhost:8000/rss?channel=@durov&limit=20" -o feed.xml

# Pretty print JSON
curl "http://localhost:8000/json?channel=@durov&limit=10" | jq .

# Download a specific media file
curl "http://localhost:8000/download/-1001234567890/12345/9876543210" -o image.jpg
```

---

## 🐛 Troubleshooting / عیب‌یابی

<div dir="rtl">

### مشکلات رایج و راه‌حل‌ها

#### سرویس شروع نمی‌شود

</div>

### Common Issues and Solutions

#### Service won't start

```bash
# Check logs
journalctl --user -u rss-telegram.service -n 50

# Check if port is in use
lsof -i :8000

# Restart service
systemctl --user restart rss-telegram.service
```

<div dir="rtl">

#### خطای Authentication

</div>

#### Authentication Error

```bash
# Remove session and login again
rm session_name.session*
python3 login.py
```

<div dir="rtl">

#### خطای "FloodWaitError"

اگر درخواست‌های زیادی زدید، تلگرام شما را محدود می‌کند. باید چند دقیقه صبر کنید.

#### مشکل با کانال خصوصی

مطمئن شوید که:
- عضو کانال هستید
- از Channel ID صحیح استفاده می‌کنید (منفی با `-100` شروع می‌شود)
- یا از invite link استفاده می‌کنید

</div>

#### "FloodWaitError"

If you make too many requests, Telegram will rate-limit you. Wait a few minutes.

#### Private Channel Issues

Make sure:
- You are a member of the channel
- Using correct Channel ID (starts with `-100`)
- Or using the invite link

<div dir="rtl">

#### پورت 8000 در دسترس نیست

</div>

#### Port 8000 not available

```bash
# Find process using port 8000
lsof -ti:8000 | xargs kill -9

# Or change port in service file
nano ~/.config/systemd/user/rss-telegram.service
```

<div dir="rtl">

#### مشکل با Virtual Environment

</div>

#### Virtual Environment Issues

```bash
# Remove and recreate
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 🏗️ Project Structure

```
rss-telegram/
├── main.py                 # Main FastAPI application
├── login.py                # Telegram authentication script
├── setup.sh                # Automatic setup script
├── requirements.txt        # Python dependencies
├── .env.example           # Environment variables template
├── .env                   # Your environment variables (git-ignored)
├── .gitignore             # Git ignore rules
├── README.md              # This file
├── rss-telegram.service   # Systemd service file
├── session_name.session   # Telegram session (git-ignored)
├── media/                 # Downloaded media files (git-ignored)
└── venv/                  # Python virtual environment (git-ignored)
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

<div dir="rtl">

### چگونه مشارکت کنیم؟

</div>

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<div dir="rtl">

### ایده‌ها برای بهبود

- افزودن پشتیبانی از ویدیو
- Cache کردن نتایج
- پشتیبانی از چند زبان
- Dashboard مدیریتی
- Docker support
- Authentication برای API

</div>

### Improvement Ideas

- Add video support
- Implement caching
- Multi-language support
- Admin dashboard
- Docker support
- API authentication

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

<div dir="rtl">

### تشکر ویژه از

</div>

Special thanks to:

- [FastAPI](https://fastapi.tiangolo.com/) - Modern web framework
- [Telethon](https://docs.telethon.dev/) - Telegram client library
- [Uvicorn](https://www.uvicorn.org/) - ASGI server

---

## 📞 Support

<div dir="rtl">

### پشتیبانی

اگر مشکلی داشتید:

1. ابتدا [Troubleshooting](#-troubleshooting--عیب-یابی) را بخوانید
2. در [Issues](https://github.com/abbasnazari-0/rss-telegram/issues) سرچ کنید
3. Issue جدید باز کنید

</div>

### Support

If you have issues:

1. First read [Troubleshooting](#-troubleshooting--عیب-یابی)
2. Search in [Issues](https://github.com/abbasnazari-0/rss-telegram/issues)
3. Open a new issue

---

## ⭐ Star History

If you find this project useful, please consider giving it a star!

<div dir="rtl">

اگر این پروژه برایتان مفید بود، لطفاً یک ستاره بدهید! ⭐

</div>

---

<div align="center">

**Made with ❤️ for the Telegram community**

<div dir="rtl">

**ساخته شده با ❤️ برای جامعه تلگرام**

</div>

[⬆ بازگشت به بالا](#-telegram-rss-generator)

</div>
