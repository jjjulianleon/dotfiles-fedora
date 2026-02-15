#!/bin/bash
# Script para lanzar Antigravity con parches de compatibilidad para Fedora 43

# Forzar a BoringSSL a ignorar fallos de FIPS y RNG (específico para binarios de Google)
export BORINGSSL_FIPS_SELFTEST_DIRECTORY=/dev/null
export BORINGSSL_FIPS=0

# Evitar que Electron intente usar el Keyring de GNOME/KDE que causa el freeze en Fedora 43
export ELECTRON_FORCE_KEYRING_BACKEND=basic

# Lanzar con máxima compatibilidad
echo "INFO: Se recomienda usar Dev Containers para evitar crasheos en Fedora 43."
echo "      Asegúrate de tener instalada la extensión 'Dev Containers' (ms-vscode-remote.remote-containers)."
/usr/bin/antigravity --password-store=basic --no-sandbox --disable-gpu-sandbox "$@"
