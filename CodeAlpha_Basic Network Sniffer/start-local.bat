@echo off
REM ────────────────────────────────────────────────────────
REM  Packet Sniffer Dashboard — Windows local startup
REM  Double-click this file, or run: start-local.bat
REM ────────────────────────────────────────────────────────

echo.
echo  =========================================
echo   PACKET SNIFFER - LOCAL SETUP (Windows)
echo  =========================================
echo.

REM ── Check Node.js ────────────────────────────────────────
where node >nul 2>&1
if errorlevel 1 (
    echo [!] Node.js not found.
    echo     Download from: https://nodejs.org  (v20 or newer^)
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VER=%%i
echo [OK] Node.js %NODE_VER%

REM ── Check pnpm ───────────────────────────────────────────
where pnpm >nul 2>&1
if errorlevel 1 (
    echo [!] pnpm not found. Installing...
    call npm install -g pnpm
)
for /f "tokens=*" %%i in ('pnpm -v') do set PNPM_VER=%%i
echo [OK] pnpm %PNPM_VER%

REM ── Install dependencies ──────────────────────────────────
echo.
echo [->] Installing dependencies...
call pnpm install

REM ── Start API server in a new window ─────────────────────
echo.
echo [->] Starting API server on port 5000...
start "API Server" cmd /k "set PORT=5000 && pnpm --filter @workspace/api-server run dev"

timeout /t 5 /nobreak >nul

REM ── Start dashboard in a new window ──────────────────────
echo [->] Starting dashboard on port 5173...
start "Dashboard" cmd /k "set PORT=5173 && pnpm --filter @workspace/sniffer-dashboard run dev"

echo.
echo  =========================================
echo   Dashboard:  http://localhost:5173
echo   API:        http://localhost:5000/api/packets/stats
echo  =========================================
echo.
echo   Live capture (run in a separate terminal as Administrator):
echo   python network-sniffer\sniffer.py --json ^| python network-sniffer\bridge.py
echo.
echo   Close the two terminal windows to stop the servers.
pause
