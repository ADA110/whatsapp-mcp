# WhatsApp MCP Server - Easy Setup Guide

This guide will help you set up the WhatsApp MCP Server quickly and easily, even if you're not familiar with coding.

## 🚀 Quick Start (Automated Installation)

### For macOS and Linux Users

1. **Open Terminal** and run:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

2. **Follow the prompts** - the script will automatically install all dependencies

3. **Start the services**:
   ```bash
   ./start_whatsapp_bridge.sh
   ```
   Then in another terminal:
   ```bash
   ./start_mcp_server.sh
   ```


## 📋 What Gets Installed

The automated installer will install:

- **Homebrew** (on macOS, if not already installed)
- **Go** (programming language for the WhatsApp bridge)
- **Python 3.11+** (programming language for the MCP server)
- **UV** (Python package manager)
- **Git** (version control system)

## 🔧 Manual Installation (If Automated Fails)

If the automated installation doesn't work, you can install dependencies manually:

### 1. Install Homebrew (macOS only)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Go
- **macOS**: `brew install go`
- **Linux**: Download from [golang.org](https://golang.org/dl/)

### 3. Install Python 3.11+
- **macOS**: `brew install python@3.11`
- **Linux**: `sudo apt install python3.11 python3.11-venv python3.11-pip`

### 4. Install UV
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```


## 🎯 After Installation

### Step 1: Start the WhatsApp Bridge
```bash
./start_whatsapp_bridge.sh
```

You'll see a QR code in the terminal. **Scan this QR code with your WhatsApp mobile app** to authenticate.

### Step 2: Start the MCP Server
```bash
./start_mcp_server.sh
```

### Step 3: Configure Cursor

The installer automatically creates the configuration file, but you may need to restart Cursor.

**For Cursor:**
- Restart Cursor
- You should see WhatsApp as an available integration

## 🔍 Troubleshooting

### Common Issues

**1. "Command not found" errors**
- Make sure you've restarted your terminal after installation
- Check that the programs are in your PATH

**2. QR code not showing**
- Make sure your terminal supports displaying QR codes
- Try running in a different terminal

**3. "Permission denied" on macOS/Linux**
- Run: `chmod +x install.sh`
- Or run: `sudo ./install.sh` (not recommended)

**4. Python version issues**
- Make sure you have Python 3.11 or higher
- Check with: `python3 --version`


### Getting Help

1. **Check the logs** - Look for error messages in the terminal
2. **Restart everything** - Close all terminals and restart
3. **Check dependencies** - Make sure all required software is installed
4. **Read the README** - Check the main README.md for more details

## 🎉 Success!

Once everything is working, you can:

- **Search your WhatsApp messages** through Claude/Cursor
- **Send messages** to contacts and groups
- **Send media files** (images, videos, documents, audio)
- **Download media** from your WhatsApp conversations

## 📱 Using WhatsApp MCP

### Available Commands

- `search_contacts` - Find contacts by name or phone number
- `list_messages` - Get messages with filters
- `list_chats` - List all your chats
- `send_message` - Send a text message
- `send_file` - Send a media file
- `send_audio_message` - Send an audio message
- `download_media` - Download media from messages

### Example Usage

Ask Cursor things like:
- "Show me my recent messages with John"
- "Send a message to +1234567890 saying 'Hello!'"
- "Find all messages containing 'meeting' from last week"
- "Send this image to the family group"

## 🔒 Security Notes

- All your messages are stored locally on your computer
- No data is sent to external services unless you explicitly ask
- The WhatsApp bridge only connects to WhatsApp's official servers
- Your authentication is stored securely on your device

## 🆘 Still Having Issues?

1. **Check the main README.md** for detailed technical information
2. **Open an issue** on GitHub if you find a bug
3. **Ask for help** in the project discussions

---

**Happy chatting with AI! 🤖💬**
