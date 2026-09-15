@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (echo Node.js 20 or newer is required. & pause & exit /b 1)
echo AERIS R - open http://localhost:8080
node scripts/serve.mjs
pause
