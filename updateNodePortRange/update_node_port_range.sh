#!/bin/bash

set -e

MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
FLAG="--service-node-port-range=443-32767"

# Require root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Check if the flag already exists
if grep -q -- "$FLAG" "$MANIFEST"; then
  echo "✅ Flag already present. No changes needed."
else
  echo "➕ Adding flag to kube-apiserver manifest..."

  # Backup before modifying
  cp "$MANIFEST" "${MANIFEST}.bak"

  # Modify using yq with sudo
  sudo yq -i '(.spec.containers[0].command) += ["'"$FLAG"'"]' "$MANIFEST"

  echo "✅ Flag added successfully. kube-apiserver will restart automatically."
fi
