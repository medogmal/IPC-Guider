@echo off
echo ========================================
echo IPC Guider - Fresh Run Script
echo ========================================
echo.
echo This script will:
echo 1. Clean Flutter build cache
echo 2. Get dependencies
echo 3. Run the app in Chrome
echo.
echo IMPORTANT: After the app opens in Chrome:
echo - Press Ctrl + Shift + R to hard refresh
echo - Or press Ctrl + Shift + Delete to clear cache
echo.
pause

echo.
echo [1/3] Cleaning Flutter cache...
call flutter clean

echo.
echo [2/3] Getting dependencies...
call flutter pub get

echo.
echo [3/3] Running app in Chrome...
echo.
echo ========================================
echo REMEMBER: Press Ctrl + Shift + R in Chrome!
echo ========================================
echo.
call flutter run -d chrome

pause

