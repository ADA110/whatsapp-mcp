#!/bin/bash
# Start MCP Server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/whatsapp-mcp-server"

echo "Starting WhatsApp MCP Server..."
echo "Make sure the WhatsApp Bridge is running first!"

uv run main.py
