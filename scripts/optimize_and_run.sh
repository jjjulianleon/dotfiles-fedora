#!/bin/bash
set -e

echo "=== Optimizing Boot Image Size ==="
echo "Enabling 'Host-Only' mode to shrink initramfs from ~200MB to ~50MB."

CONF="/etc/dracut.conf.d/optimization.conf"

# Configure Dracut for maximum space saving
# hostonly="yes": Only install drivers for this specific hardware
# compress="xz": Use high compression
cat <<EOF | sudo tee "$CONF"
hostonly="yes"
compress="xz"
EOF

echo "--> Configuration updated:"
cat "$CONF"

echo "=== Retrying NVIDIA Fix (Optimized) ==="
~/final_nvidia_fix.sh
