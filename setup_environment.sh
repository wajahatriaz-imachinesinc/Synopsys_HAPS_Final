#!/bin/bash

################################################################################
# HAPS-200 Environment Setup Script
# Configures PATH for hTools (hUtils, hRun) utilities
#
# Usage:
#   # For current session only:
#   source ./setup_environment.sh
#
#   # To add permanently to ~/.bashrc:
#   ./setup_environment.sh permanent
#
################################################################################

HTOOLS_PATH="/opt/synopsys/hapshwutils/V-2025.06/bin"

# Check if hTools installation exists
if [ ! -d "$HTOOLS_PATH" ]; then
    echo "❌ Error: hTools not found at $HTOOLS_PATH"
    echo "   Please verify Synopsys hTools installation location"
    exit 1
fi

# Add to PATH for current session
export PATH="${HTOOLS_PATH}:$PATH"

# Verify tools are available
if command -v hUtils &> /dev/null && command -v hRun &> /dev/null; then
    echo "✅ hTools environment configured successfully!"
    echo ""
    echo "Available tools:"
    echo "  • hUtils  - HAPS board utilities (programming, monitoring)"
    echo "  • hRun    - HAPS runtime testing & debug"
    echo ""
    echo "Quick commands:"
    echo "  hUtils -scan               # Scan for HAPS boards"
    echo "  hUtils -status             # Check board status"
    echo "  hRun -project [prj] -interactive  # Run tests"
else
    echo "❌ Error: Could not find hUtils or hRun in PATH"
    exit 1
fi

# Handle permanent installation
if [ "$1" == "permanent" ]; then
    echo ""
    echo "Adding to ~/.bashrc for permanent configuration..."
    
    BASHRC_ENTRY="export PATH=\"${HTOOLS_PATH}:\$PATH\"  # hTools (added by setup_environment.sh)"
    
    # Check if already in bashrc
    if grep -q "$HTOOLS_PATH" ~/.bashrc 2>/dev/null; then
        echo "⚠️  hTools PATH already in ~/.bashrc"
    else
        echo "$BASHRC_ENTRY" >> ~/.bashrc
        echo "✅ Added to ~/.bashrc"
        echo ""
        echo "Apply changes:"
        echo "  source ~/.bashrc"
    fi
fi

echo ""
echo "Ready for deployment! Run:"
echo "  cd /projects/users/wriaz/Synopsys_HAPS_Final"
echo "  ./deploy.sh full"
