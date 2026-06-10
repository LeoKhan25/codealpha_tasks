#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
# Packet Sniffer Dashboard — local startup script
# Run: bash start-local.sh
# ─────────────────────────────────────────────────────────
set -e

# ── colours ──────────────────────────────────────────────
BOLD="\033[1m"; GREEN="\033[92m"; CYAN="\033[96m"
YELLOW="\033[93m"; RESET="\033[0m"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║${RESET}${CYAN}   PACKET SNIFFER — LOCAL SETUP          ${RESET}${BOLD}║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Check Node.js ─────────────────────────────────────
if ! command -v node &>/dev/null; then
  echo -e "${YELLOW}[!] Node.js not found.${RESET}"
  echo "    Install from: https://nodejs.org  (v20 or newer)"
  exit 1
fi
NODE_VER=$(node -v)
echo -e "${GREEN}[✓]${RESET} Node.js $NODE_VER"

# ── 2. Check pnpm ─────────────────────────────────────────
if ! command -v pnpm &>/dev/null; then
  echo -e "${YELLOW}[!] pnpm not found. Installing...${RESET}"
  npm install -g pnpm
fi
echo -e "${GREEN}[✓]${RESET} pnpm $(pnpm -v)"

# ── 3. Install JS dependencies ────────────────────────────
echo ""
echo -e "${CYAN}[→] Installing dependencies...${RESET}"
pnpm install

# ── 4. Install Python deps (optional, for live capture) ──
if command -v pip3 &>/dev/null; then
  echo -e "${CYAN}[→] Installing Python sniffer dependencies...${RESET}"
  pip3 install -q scapy 2>/dev/null && echo -e "${GREEN}[✓]${RESET} scapy installed" \
    || echo -e "${YELLOW}[!] scapy install failed — live capture won't work (dashboard still runs fine)${RESET}"
fi

# ── 5. Start API server in background ────────────────────
echo ""
echo -e "${CYAN}[→] Starting API server on port 5000...${RESET}"
PORT=5000 pnpm --filter @workspace/api-server run dev &
API_PID=$!

sleep 3  # give the API server a moment to compile and start

# ── 6. Start dashboard ────────────────────────────────────
echo -e "${CYAN}[→] Starting dashboard on port 5173...${RESET}"
echo ""
echo -e "${BOLD}  Dashboard:${RESET}  ${GREEN}http://localhost:5173${RESET}"
echo -e "${BOLD}  API:       ${RESET}  ${GREEN}http://localhost:5000/api/packets/stats${RESET}"
echo ""
echo -e "${YELLOW}  To enable live capture, open a new terminal and run:${RESET}"
echo -e "  ${CYAN}sudo python3 network-sniffer/sniffer.py --json | python3 network-sniffer/bridge.py${RESET}"
echo ""
echo -e "  Press ${BOLD}Ctrl+C${RESET} to stop everything."
echo ""

# Cleanup both processes on exit
trap "kill $API_PID 2>/dev/null; exit" INT TERM

PORT=5173 pnpm --filter @workspace/sniffer-dashboard run dev
