#!/usr/bin/env bash
set -euo pipefail
flutter create --platforms=android,web,windows,linux,macos .
flutter pub get
flutter analyze
