#!/bin/bash

echo "🧹 Cleaning Flutter build cache..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building macOS app with network permissions..."
flutter build macos --debug

echo "✅ Build complete! The app should now have network permissions."
echo ""
echo "If you still get permission errors:"
echo "1. Go to System Settings → Privacy & Security → Network"
echo "2. Look for 'binance_transaction_app' or 'Flutter'"
echo "3. Make sure it's enabled"
echo ""
echo "You can also run the app with:"
echo "flutter run -d macos"