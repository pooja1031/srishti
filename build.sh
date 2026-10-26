#!/bin/bash
set -e

# Install Flutter SDK if it is not available
if [ ! -d "$HOME/flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 --branch stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "Configuring Flutter Web..."
flutter config --enable-web

echo "Installing dependencies..."
flutter pub get

echo "Building web release..."
flutter build web --release
