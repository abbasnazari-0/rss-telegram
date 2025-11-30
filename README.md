# 🚀 Telegram RSS API

تبدیل کانال‌های تلگرام (پابلیک و پرایوت) به RSS فید با یک خط دستور!

## ✨ ویژگی‌ها

- 🔐 پشتیبانی کامل از کانال‌های پرایوت و پابلیک
- 📸 دانلود و سرو عکس‌ها (تک عکس و آلبوم)
- 📡 REST API با FastAPI
- 🐳 نصب آسان با Docker
- 📱 خروجی RSS و JSON
- 🔄 Auto-restart و healthcheck
- ⚡ پشتیبانی از limit بالا (تا 1000 پست)

## 🚀 نصب سریع (یک خط!)
```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/telegram-rss-api/main/setup.sh | sudo bash
```

یا دستی:
```bash
git clone https://github.com/YOUR_USERNAME/telegram-rss-api.git
cd telegram-rss-api
sudo chmod +x setup.sh
sudo ./setup.sh
```

اسکریپت نصب به صورت خودکار:
1. ✅ Docker و Docker Compose را نصب می‌کند
2. ✅ اطلاعات API شما را می‌گیرد
3. ✅ شما را لاگین می‌کند
4. ✅ سرویس را راه‌اندازی می‌کند

## 📋 پیش‌نیازها

1. API credentials از https://my.telegram.org
2. سرور Ubuntu/Debian با دسترسی root
3. شماره تلگرام فعال

## 📖 استفاده از API

### دریافت RSS فید:
```bash
# کانال پابلیک
curl "http://localhost:8000/rss?channel=@durov&limit=50"

# کانال پرایوت با Channel ID
curl "http://localhost:8000/rss?channel=-1001234567890&limit=20"

# کانال پرایوت با لینک دعوت
curl "http://localhost:8000/rss?channel=https://t.me/+ABC123&limit=10"
```

### دریافت JSON:
```bash
curl "http://localhost:8000/json?channel=@telegram&limit=30"
```

### دانلود عکس:
```bash
curl "http://localhost:8000/download/{channel_id}/{msg_id}/{media_id}" -o image.jpg
```

### مستندات کامل API:
```
http://YOUR_SERVER:8000/docs
```

## 🛠 مدیریت سرویس
```bash
# مشاهده لاگ‌ها
docker-compose logs -f

# ری‌استارت
docker-compose restart

# خاموش کردن
docker-compose down

# روشن کردن
docker-compose up -d

# مشاهده وضعیت
docker-compose ps
```

## 🌐 دسترسی از خارج

برای دسترسی از اینترنت:

### با Nginx Reverse Proxy:
```bash
sudo apt install nginx -y

sudo nano /etc/nginx/sites-available/telegram-rss
```
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
```bash
sudo ln -s /etc/nginx/sites-available/telegram-rss /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### با ngrok (برای تست):
```bash
ngrok http 8000
```

## 📊 مثال‌های کاربردی

### استفاده در RSS Reader:
```
http://your-server:8000/rss?channel=-1001234567890&limit=100
```

### گرفتن آخرین پست‌ها:
```bash
curl "http://localhost:8000/json?channel=@channelname&limit=10" | jq '.messages[0]'
```

### دانلود همه عکس‌های یک پست:
```bash
curl "http://localhost:8000/json?channel=@channel&limit=1" | \
  jq -r '.messages[0].media[].download_url' | \
  while read url; do
    curl "http://localhost:8000$url" -o "image_$(basename $url).jpg"
  done
```

## 🔧 عیب‌یابی

### سرویس اجرا نمی‌شود:
```bash
docker-compose logs
```

### مشکل در لاگین:
1. API credentials را چک کنید
2. شماره تلگرام را با کد کشور وارد کنید (+98...)
3. فایل session را پاک کنید و دوباره امتحان کنید:
```bash
rm session_name.session*
docker-compose restart
```

### پورت 8000 در حال استفاده است:
در `docker-compose.yml` پورت را تغییر دهید:
```yaml
ports:
  - "8080:8000"  # به جای 8000
```

## 🤝 مشارکت

مشارکت‌ها خوش‌آمدید! لطفاً:
1. Fork کنید
2. یک branch جدید بسازید
3. تغییرات خود را commit کنید
4. یک Pull Request ارسال کنید

## 📝 لایسنس

MIT License - استفاده آزاد برای همه!

## 🙏 قدردانی

- [Telethon](https://github.com/LonamiWebs/Telethon) - کتابخانه عالی تلگرام
- [FastAPI](https://fastapi.tiangolo.com/) - فریمورک سریع و مدرن

## 📞 پشتیبانی

اگر مشکلی داشتید، یک Issue باز کنید یا در Discussions بپرسید.

---

ساخته شده با ❤️ برای جامعه متن‌باز