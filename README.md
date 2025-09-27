# WhatsApp MCP Server

This is a Model Context Protocol (MCP) server for WhatsApp.

With this you can search and read your personal Whatsapp messages (including images, videos, documents, and audio messages), search your contacts and send messages to either individuals or groups. You can also send media files including images, videos, documents, and audio messages.

It connects to your **personal WhatsApp account** directly via the Whatsapp web multidevice API (using the [whatsmeow](https://github.com/tulir/whatsmeow) library). All your messages are stored locally in a SQLite database and only sent to an LLM (such as Claude) when the agent accesses them through tools (which you control).

Here's an example of what you can do when it's connected to Claude.

![WhatsApp MCP](./example-use.png)

> To get updates on this and other projects I work on [enter your email here](https://docs.google.com/forms/d/1rTF9wMBTN0vPfzWuQa2BjfGKdKIpTbyeKxhPMcEzgyI/preview)

> *Caution:* as with many MCP servers, the WhatsApp MCP is subject to [the lethal trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/). This means that project injection could lead to private data exfiltration.

## 🚀 Quick Installation (Recommended)

### Automated Installation

For the easiest setup, use our automated installer:

**Prerequisites:**
- macOS or Linux
- Git (for cloning the repository)
- Cursor IDE
- All other dependencies will be installed automatically

**Installing Git:**
- **macOS**: Git comes pre-installed, or install via [Homebrew](https://brew.sh/): `brew install git`
- **Linux**: Install via package manager:
  - Ubuntu/Debian: `sudo apt update && sudo apt install git`
  - CentOS/RHEL: `sudo yum install git` or `sudo dnf install git`
  - Arch Linux: `sudo pacman -S git`

**One-Step Setup:**
```bash
git clone https://github.com/ADA110/whatsapp-mcp.git
cd whatsapp-mcp
chmod +x launch.sh
./launch.sh
```

**Menu Options (in order):**
1. **First time setup**: Select option **8** (Install/Update Dependencies)
2. **Start WhatsApp Bridge**: Select option **1** (Start WhatsApp Bridge) - scan QR code when prompted
3. **Start MCP Server**: Select option **2** (Start MCP Server) - in a new terminal or after bridge is running
4. **Daily usage**: Select option **3** (Start Both Services) to run everything at once
5. **Stop services**: Select option **4** (Force Kill All Processes) - most reliable way to stop
6. **Troubleshooting**: Select option **5** (Show Status) if you get "service is running" message

The installer will automatically:
- Install Homebrew (on macOS) if not already installed
- Install all required dependencies (Go, Python, UV)
- Set up the project
- Create configuration files
- Generate startup scripts

### Easy Launcher

Use the launcher for all operations:

**macOS and Linux:**
```bash
./launch.sh
```

**Complete Workflow:**

1. **Initial Setup** (one-time):
   - Run `./launch.sh`
   - Select option **8** (Install/Update Dependencies)
   - Wait for installation to complete
   - Exit the launcher

2. **First Time Connection**:
   - Run `./launch.sh` again
   - Select option **1** (Start WhatsApp Bridge)
   - Scan the QR code with your WhatsApp mobile app
   - Wait for "Connected" message
   - Press Ctrl+C to stop the bridge

3. **Start Services** (daily usage):
   - Run `./launch.sh`
   - Select option **3** (Start Both Services)
   - Both WhatsApp Bridge and MCP Server will start
   - Keep this terminal open while using WhatsApp features

4. **Stop Services**:
   - In the launcher, select option **4** (Force Kill All Processes)
   - Or press Ctrl+C in the terminal where services are running

5. **Troubleshooting**:
   - If you get "service is running" message, select option **5** (Show Status) to check what's actually running
   - Use option **4** (Force Kill All Processes) to stop any stuck services

## 📋 Manual Installation

If you prefer to install manually or the automated installer doesn't work:

### Prerequisites

- macOS or Linux
- Git (for cloning the repository)
- Cursor IDE
- All other dependencies will be installed automatically by the installer

**Installing Git:**
- **macOS**: Git comes pre-installed, or install via [Homebrew](https://brew.sh/): `brew install git`
- **Linux**: Install via package manager:
  - Ubuntu/Debian: `sudo apt update && sudo apt install git`
  - CentOS/RHEL: `sudo yum install git` or `sudo dnf install git`
  - Arch Linux: `sudo pacman -S git`

### Steps

1. **Clone this repository**

   ```bash
   git clone https://github.com/ADA110/whatsapp-mcp.git
   cd whatsapp-mcp
   ```

2. **Run the WhatsApp bridge**

   Navigate to the whatsapp-bridge directory and run the Go application:

   ```bash
   cd whatsapp-bridge
   go run main.go
   ```

   The first time you run it, you will be prompted to scan a QR code. Scan the QR code with your WhatsApp mobile app to authenticate.

   After approximately 20 days, you will might need to re-authenticate.

3. **Connect to the MCP server**

   Copy the below json with the appropriate {{PATH}} values:

   ```json
   {
     "mcpServers": {
       "whatsapp": {
         "command": "{{PATH_TO_UV}}", // Run `which uv` and place the output here
         "args": [
           "--directory",
           "{{PATH_TO_SRC}}/whatsapp-mcp/whatsapp-mcp-server", // cd into the repo, run `pwd` and enter the output here + "/whatsapp-mcp-server"
           "run",
           "main.py"
         ]
       }
     }
   }
   ```

   Save this as `mcp.json` in your Cursor configuration directory at:

   ```
   ~/.cursor/mcp.json
   ```

4. **Restart Cursor**

   Restart Cursor and you should now see WhatsApp as an available integration.

## 📖 Detailed Setup Guide

For a comprehensive, step-by-step guide with troubleshooting tips, see [SETUP_GUIDE.md](SETUP_GUIDE.md).



## Architecture Overview

This application consists of two main components:

1. **Go WhatsApp Bridge** (`whatsapp-bridge/`): A Go application that connects to WhatsApp's web API, handles authentication via QR code, and stores message history in SQLite. It serves as the bridge between WhatsApp and the MCP server.

2. **Python MCP Server** (`whatsapp-mcp-server/`): A Python server implementing the Model Context Protocol (MCP), which provides standardized tools for Cursor to interact with WhatsApp data and send/receive messages.

### Data Storage

- All message history is stored in a SQLite database within the `whatsapp-bridge/store/` directory
- The database maintains tables for chats and messages
- Messages are indexed for efficient searching and retrieval

## Usage

Once connected, you can interact with your WhatsApp contacts through Cursor, leveraging Cursor's AI capabilities in your WhatsApp conversations.

### MCP Tools

Cursor can access the following tools to interact with WhatsApp:

- **search_contacts**: Search for contacts by name or phone number
- **list_messages**: Retrieve messages with optional filters and context
- **list_chats**: List available chats with metadata
- **get_chat**: Get information about a specific chat
- **get_direct_chat_by_contact**: Find a direct chat with a specific contact
- **get_contact_chats**: List all chats involving a specific contact
- **get_last_interaction**: Get the most recent message with a contact
- **get_message_context**: Retrieve context around a specific message
- **send_message**: Send a WhatsApp message to a specified phone number or group JID
- **send_file**: Send a file (image, video, raw audio, document) to a specified recipient
- **send_audio_message**: Send an audio file as a WhatsApp voice message (requires the file to be an .ogg opus file)
- **download_media**: Download media from a WhatsApp message and get the local file path

### Media Handling Features

The MCP server supports both sending and receiving various media types:

#### Media Sending

You can send various media types to your WhatsApp contacts:

- **Images, Videos, Documents**: Use the `send_file` tool to share any supported media type.
- **Voice Messages**: Use the `send_audio_message` tool to send audio files as playable WhatsApp voice messages.
  - Audio files must be in `.ogg` Opus format to work as voice messages.
  - You can also send raw audio files using the `send_file` tool, but they won't appear as playable voice messages.

#### Media Downloading

By default, just the metadata of the media is stored in the local database. The message will indicate that media was sent. To access this media you need to use the download_media tool which takes the `message_id` and `chat_jid` (which are shown when printing messages containing the meda), this downloads the media and then returns the file path which can be then opened or passed to another tool.

## Technical Details

1. Cursor sends requests to the Python MCP server
2. The MCP server queries the Go bridge for WhatsApp data or directly to the SQLite database
3. The Go accesses the WhatsApp API and keeps the SQLite database up to date
4. Data flows back through the chain to Cursor
5. When sending messages, the request flows from Cursor through the MCP server to the Go bridge and to WhatsApp

## Troubleshooting

- If you encounter permission issues when running uv, you may need to add it to your PATH or use the full path to the executable.
- **UV Installation Failed**: If the automated UV installation fails, try installing it manually:
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
  Then restart your terminal or run `source ~/.cargo/env` to add UV to your PATH.
- **UV Command Not Found**: If you get "uv: command not found" after installation, the installer automatically adds UV to your shell profile files, but you may need to:
  - Restart your terminal, OR
  - Run `source ~/.cargo/env` in your current terminal session
  - The installer will use the full path to UV (`~/.cargo/bin/uv`) in the configuration as a fallback
- Make sure both the Go application and the Python server are running for the integration to work properly.

### Authentication Issues

- **QR Code Not Displaying**: If the QR code doesn't appear, try restarting the authentication script. If issues persist, check if your terminal supports displaying QR codes.
- **WhatsApp Already Logged In**: If your session is already active, the Go bridge will automatically reconnect without showing a QR code.
- **Device Limit Reached**: WhatsApp limits the number of linked devices. If you reach this limit, you'll need to remove an existing device from WhatsApp on your phone (Settings > Linked Devices).
- **No Messages Loading**: After initial authentication, it can take several minutes for your message history to load, especially if you have many chats.
- **WhatsApp Out of Sync**: If your WhatsApp messages get out of sync with the bridge, delete both database files (`whatsapp-bridge/store/messages.db` and `whatsapp-bridge/store/whatsapp.db`) and restart the bridge to re-authenticate.

For additional Claude Desktop integration troubleshooting, see the [MCP documentation](https://modelcontextprotocol.io/quickstart/server#claude-for-desktop-integration-issues). The documentation includes helpful tips for checking logs and resolving common issues.
