#!/usr/bin/env python3
"""
Login script for Telegram RSS Generator
This script helps you authenticate with Telegram and create a session file
"""

import os
import sys
from telethon import TelegramClient
from dotenv import load_dotenv

def main():
    # Load environment variables
    load_dotenv()
    
    # Get credentials from environment
    api_id = os.getenv('API_ID')
    api_hash = os.getenv('API_HASH')
    phone = os.getenv('PHONE')
    session_name = os.getenv('SESSION_NAME', 'session_name')
    
    # Validate credentials
    if not all([api_id, api_hash, phone]):
        print("❌ Error: Missing credentials in .env file")
        print("\nPlease make sure your .env file contains:")
        print("  - API_ID")
        print("  - API_HASH")
        print("  - PHONE")
        print("\nGet your API credentials from: https://my.telegram.org/apps")
        sys.exit(1)
    
    try:
        api_id = int(api_id)
    except ValueError:
        print("❌ Error: API_ID must be a number")
        sys.exit(1)
    
    print("🔐 Telegram RSS Generator - Login")
    print("=" * 50)
    print(f"📱 Phone: {phone}")
    print(f"🔑 API ID: {api_id}")
    print("=" * 50)
    print("\n⏳ Connecting to Telegram...\n")
    
    # Create client
    client = TelegramClient(session_name, api_id, api_hash)
    
    async def login():
        await client.connect()
        
        if not await client.is_user_authorized():
            print("📲 Sending authentication code to your phone...")
            await client.send_code_request(phone)
            
            print("\n✅ Code sent!")
            code = input("🔢 Enter the code you received: ")
            
            try:
                await client.sign_in(phone, code)
                print("\n✅ Successfully logged in!")
            except Exception as e:
                if "Two-steps verification" in str(e) or "SessionPasswordNeededError" in str(e):
                    password = input("🔐 Two-step verification enabled. Enter your password: ")
                    await client.sign_in(password=password)
                    print("\n✅ Successfully logged in with 2FA!")
                else:
                    raise e
        else:
            print("✅ Already logged in!")
        
        # Test the connection
        me = await client.get_me()
        print("\n" + "=" * 50)
        print(f"👤 Logged in as: {me.first_name} {me.last_name or ''}")
        print(f"📱 Phone: {me.phone}")
        print(f"🆔 User ID: {me.id}")
        print("=" * 50)
        print(f"\n✅ Session file created: {session_name}.session")
        print("🚀 You can now run the service with: ./setup.sh")
        
        await client.disconnect()
    
    try:
        client.loop.run_until_complete(login())
    except KeyboardInterrupt:
        print("\n\n❌ Login cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error during login: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
