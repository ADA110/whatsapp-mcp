#!/bin/bash
# Start WhatsApp Bridge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/whatsapp-bridge"

echo "Starting WhatsApp Bridge..."
echo "Scan the QR code with your WhatsApp mobile app to authenticate."
echo "Press Ctrl+C to stop the bridge."

./main
