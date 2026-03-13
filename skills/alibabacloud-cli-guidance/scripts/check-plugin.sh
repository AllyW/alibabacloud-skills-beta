#!/bin/bash
# Check if an Aliyun CLI plugin is installed

set -e

PLUGIN_NAME=$1

if [ -z "$PLUGIN_NAME" ]; then
    echo "Usage: $0 <plugin-name>"
    echo "Example: $0 ecs"
    exit 1
fi

echo "Checking if plugin '$PLUGIN_NAME' is installed..."

if aliyun plugin list 2>/dev/null | grep -q "aliyun-cli-$PLUGIN_NAME"; then
    echo "✓ Plugin '$PLUGIN_NAME' is installed"

    # Show plugin version
    VERSION=$(aliyun plugin list 2>/dev/null | grep "aliyun-cli-$PLUGIN_NAME" | awk '{print $2}')
    echo "  Version: $VERSION"

    exit 0
else
    echo "✗ Plugin '$PLUGIN_NAME' is NOT installed"
    echo ""
    echo "To install, run:"
    echo "  aliyun plugin install --names $PLUGIN_NAME"

    exit 1
fi
