# Telegram RSS Generator API 📢

Convert Telegram channels into RSS feeds automatically. This tool runs as a system service and handles media downloads.

## 🚀 Quick Install (Ubuntu/Debian)

1. **Clone the repo:**
   ```bash
   git clone https://github.com/abbasnazari-0/rss-telegram.git
   cd REPO
Run the installer:
code
Bash
chmod +x setup.sh
sudo ./setup.sh
Follow the instructions:
The script will ask for your API ID/Hash.
It will run the app once manually. Enter your login code.
After you see "Connected", press Ctrl+C.
The script will automatically install it as a background service.
⚙️ Manage Service
Stop: sudo systemctl stop telegram-rss
Restart: sudo systemctl restart telegram-rss
Logs: sudo journalctl -u telegram-rss -f
🔗 Usage
Access your feeds at:
http://YOUR_IP:8000/rss?channel=@channelname
