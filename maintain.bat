@echo off
echo --- Starting Poco M3 Daily Maintenance ---

:: Check if device is connected
"%~dp0adb.exe" get-state >nul 2>&1
if errorlevel 1 (
    echo [!] Error: ADB not responding.
    echo [!] check if phone is plugged in and screen is unlocked.
    pause
    exit /b
)

:: 1. TRIM STORAGE
echo [*] Trimming filesystem...
"%~dp0adb.exe" shell sm fstrim

:: 2. SYNC FILESYSTEM
echo [*] Syncing filesystem...
"%~dp0adb.exe" shell sync

:: 3. KILL BACKGROUND PROCESSES
echo [*] Killing background processes...
"%~dp0adb.exe" shell am kill-all

:: 4. OPTIMIZE LAUNCHER
echo [*] Optimizing Launcher...
"%~dp0adb.exe" shell cmd package compile -m speed -f com.mi.android.globallauncher

:: 5. FORCE DEEP SLEEP
echo [*] Forcing Deep Sleep...
"%~dp0adb.exe" shell dumpsys deviceidle force-idle

:: 6. FORCE SKIAGL RENDERING
echo [*] Forcing SkiaGL Rendering...
"%~dp0adb.exe" shell setprop debug.hwui.renderer skiagl

:: 7. OPTIMIZE NETWORK (Reduce Ping Spikes)
echo [*] Disabling Background Scans...
"%~dp0adb.exe" shell settings put global wifi_scan_always_enabled 0
"%~dp0adb.exe" shell settings put global ble_scan_always_enabled 0

echo [*] Setting High-Performance DNS (Cloudflare)...
"%~dp0adb.exe" shell settings put global private_dns_mode hostname
"%~dp0adb.exe" shell settings put global private_dns_specifier 1dot1dot1dot1.cloudflare-dns.com

:: 8. TOUCH SENSITIVITY (Competitive Mode)
echo [*] Tuning Touch Driver...
:: Reduce tap delay (Default is usually higher)
"%~dp0adb.exe" shell settings put secure tap_duration_threshold 0
:: Reduce long-press delay (Snappier menus)
"%~dp0adb.exe" shell settings put secure long_press_timeout 250
:: Disable "Touch Slop" (Registers smaller movements faster)
"%~dp0adb.exe" shell settings put system touch.pressure.scale 0.001

:: 9. SYSTEM SILENCING (Reduce CPU Overhead)
echo [*] shrinking Logcat Buffer...
"%~dp0adb.exe" shell logcat -G 64K
echo [*] Disabling Dropbox Logging...
"%~dp0adb.exe" shell settings put global dropbox_max_files 0

echo --- Maintenance Complete ---
pause