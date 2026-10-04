#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg install -y git curl unzip zip wget openssh
printf '\nTermux siap untuk Git.\n'
printf 'Untuk Flutter, build APK yang paling stabil dilakukan oleh GitHub Actions.\n'
printf 'Workflow akan menjalankan flutter create, flutter pub get, analyze, dan build APK.\n'
