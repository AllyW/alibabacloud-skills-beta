#!/bin/bash
# Install an Aliyun CLI plugin if not already installed

set -e

PLUGIN_NAME=$1

if [ -z "$PLUGIN_NAME" ]; then
    echo "Usage: $0 <plugin-name>"
    echo "Example: $0 ecs"
    exit 1
fi

echo "Checking plugin status for '$PLUGIN_NAME'..."

# Check if already installed
if aliyun plugin list 2>/dev/null | grep -q "aliyun-cli-$PLUGIN_NAME"; then
    VERSION=$(aliyun plugin list 2>/dev/null | grep "aliyun-cli-$PLUGIN_NAME" | awk '{print $2}')
    echo "✓ Plugin '$PLUGIN_NAME' is already installed (version: $VERSION)"

    read -p "Do you want to update it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Updating plugin '$PLUGIN_NAME'..."
        aliyun plugin update "$PLUGIN_NAME"
        echo "✓ Plugin updated successfully"
    fi
else
    echo "Installing plugin '$PLUGIN_NAME'..."
    aliyun plugin install --names "$PLUGIN_NAME"
    echo "✓ Plugin '$PLUGIN_NAME' installed successfully"

    # Show installed version
    VERSION=$(aliyun plugin list 2>/dev/null | grep "aliyun-cli-$PLUGIN_NAME" | awk '{print $2}')
    echo "  Version: $VERSION"
fi
