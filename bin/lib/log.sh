#!/bin/bash

# Log file location
LOG_FILE="${ZIDE_DIR}/tmp/logs"

# Color codes
COLOR_RESET="\033[0m"
COLOR_INFO="\033[32m"   # Green
COLOR_WARN="\033[33m"   # Yellow
COLOR_ERROR="\033[31m"  # Red

# Log levels
info() {
  local message="$1"
  echo -e "$(timestamp) ${COLOR_INFO}[INFO]${COLOR_RESET} $message" | tee -a "$LOG_FILE" >/dev/null
}

warn() {
  local message="$1"
  echo -e "$(timestamp) ${COLOR_WARN}[WARN]${COLOR_RESET} $message" | tee -a "$LOG_FILE" >/dev/null
}

error() {
  local message="$1"
  echo -e "$(timestamp) ${COLOR_ERROR}[ERROR]${COLOR_RESET} $message" | tee -a "$LOG_FILE" >/dev/null
}

# Timestamp function
timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}
