@echo off
echo --- Starting Device Daily Maintenance ---

set ADB=%~dp0platform-tools\adb.exe

if not exist "%ADB%" (
    echo [!] ADB not found.
    pause
    exit /b
)

:: Check if device is connected
"%ADB%" get-state >nul 2>&1
if errorlevel 1 (
    echo [!] Error: ADB not responding.
    echo [!] check if phone is plugged in and screen is unlocked.
    pause
    exit /b
)

:: 1. TRIM STORAGE
echo [*] Trimming filesystem...
"%ADB%" shell sm fstrim

:: 2. SYNC FILESYSTEM
echo [*] Syncing filesystem...
"%ADB%" shell sync

:: 3. KILL BACKGROUND PROCESSES
echo [*] Killing background processes...
"%ADB%" shell am kill-all

:: 4. OPTIMIZE LAUNCHER
echo [*] Optimizing Launcher...
"%ADB%" shell cmd package compile -m speed -f com.mi.android.globallauncher

:: 5. FORCE DEEP SLEEP
echo [*] Forcing Deep Sleep...
"%ADB%" shell dumpsys deviceidle force-idle

:: 6. FORCE SKIAGL RENDERING
echo [*] Forcing SkiaGL Rendering...
"%ADB%" shell setprop debug.hwui.renderer skiagl

:: 7. OPTIMIZE NETWORK (Reduce Ping Spikes)
echo [*] Disabling Background Scans...
"%ADB%" shell settings put global wifi_scan_always_enabled 0
"%ADB%" shell settings put global ble_scan_always_enabled 0

echo [*] Setting High-Performance DNS (Cloudflare)...
"%ADB%" shell settings put global private_dns_mode hostname
"%ADB%" shell settings put global private_dns_specifier 1dot1dot1dot1.cloudflare-dns.com

:: 8. TOUCH SENSITIVITY (Competitive Mode)
echo [*] Tuning Touch Driver...
:: Reduce tap delay (Default is usually higher)
"%ADB%" shell settings put secure tap_duration_threshold 0
:: Reduce long-press delay (Snappier menus)
"%ADB%" shell settings put secure long_press_timeout 250
:: Disable "Touch Slop" (Registers smaller movements faster)
"%ADB%" shell settings put system touch.pressure.scale 0.001

:: 9. SYSTEM SILENCING (Reduce CPU Overhead)
echo [*] shrinking Logcat Buffer...
"%ADB%" shell logcat -G 64K
echo [*] Disabling Dropbox Logging...
"%ADB%" shell settings put global dropbox_max_files 0

echo --- Maintenance Complete ---
pause
