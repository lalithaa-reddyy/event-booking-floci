#!/bin/bash

# Launch all monitoring scripts in parallel
# Displays real-time monitoring of:
# - CloudWatch Logs (Lambda execution)
# - DynamoDB Bookings (booking status)
# - DynamoDB Events (available events)
# - SQS Queue (messages waiting for processing)
# - S3 Buckets (uploaded tickets)

set_color() {
  case $1 in
    info) echo -e "\033[0;36m" ;;     # Cyan
    success) echo -e "\033[0;32m" ;;  # Green
    warning) echo -e "\033[0;33m" ;;  # Yellow
    error) echo -e "\033[0;31m" ;;    # Red
    reset) echo -e "\033[0m" ;;
  esac
}

print_header() {
  set_color "info"
  echo "=========================================="
  echo "$1"
  echo "=========================================="
  set_color "reset"
}

print_header "Event Booking Platform - All Monitors"

echo ""
echo "This script will launch 5 monitoring windows:"
echo "  1. CloudWatch Logs (Lambda execution logs)"
echo "  2. DynamoDB Bookings (booking data & status)"
echo "  3. DynamoDB Events (available events)"
echo "  4. SQS Queue (pending messages)"
echo "  5. S3 Buckets (uploaded tickets)"
echo ""

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if scripts exist
for script in watch-logs.sh watch-bookings.sh watch-events.sh watch-sqs.sh watch-s3.sh; do
  if [ ! -f "$SCRIPT_DIR/$script" ]; then
    set_color "error"
    echo "Error: $script not found in $SCRIPT_DIR"
    set_color "reset"
    exit 1
  fi
done

print_header "Starting Monitors"

echo ""
set_color "success"
echo "✓ All scripts found and ready"
set_color "reset"
echo ""

# Get project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Detect OS and launch appropriately
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  # Windows with Git Bash
  echo "Detected Windows environment"
  echo ""
  echo "Launching 5 PowerShell windows..."
  echo ""

  powershell -NoExit -Command "cd '$PROJECT_ROOT'; bash scripts/watch-logs.sh" &
  sleep 0.5
  powershell -NoExit -Command "cd '$PROJECT_ROOT'; bash scripts/watch-bookings.sh" &
  sleep 0.5
  powershell -NoExit -Command "cd '$PROJECT_ROOT'; bash scripts/watch-events.sh" &
  sleep 0.5
  powershell -NoExit -Command "cd '$PROJECT_ROOT'; bash scripts/watch-sqs.sh" &
  sleep 0.5
  powershell -NoExit -Command "cd '$PROJECT_ROOT'; bash scripts/watch-s3.sh" &

  echo "✓ Launched 5 monitoring windows"
  echo ""
  echo "Windows should appear momentarily. If they don't:"
  echo "  1. Open PowerShell manually"
  echo "  2. Run each script from the scripts/ directory:"
  echo "     bash watch-logs.sh"
  echo "     bash watch-bookings.sh"
  echo "     bash watch-events.sh"
  echo "     bash watch-sqs.sh"
  echo "     bash watch-s3.sh"

elif [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
  # Linux/macOS with tmux support
  if command -v tmux &> /dev/null; then
    echo "Detected Linux/macOS environment"
    echo "Launching with tmux (5 split panes)..."
    echo ""

    SESSION="booking-monitor"

    # Kill existing session if it exists
    tmux kill-session -t $SESSION 2>/dev/null || true

    # Create new session
    tmux new-session -d -s $SESSION -x 240 -y 60

    # Split into 5 panes
    tmux send-keys -t $SESSION "cd $PROJECT_ROOT && bash scripts/watch-logs.sh" Enter
    tmux split-window -t $SESSION -h "cd $PROJECT_ROOT && bash scripts/watch-bookings.sh"
    tmux split-window -t $SESSION -h "cd $PROJECT_ROOT && bash scripts/watch-events.sh"
    tmux split-window -t $SESSION -h "cd $PROJECT_ROOT && bash scripts/watch-sqs.sh"
    tmux split-window -t $SESSION -h "cd $PROJECT_ROOT && bash scripts/watch-s3.sh"

    # Balance panes
    tmux select-layout -t $SESSION tiled

    echo "✓ Launched tmux session: $SESSION"
    echo ""
    echo "To view: tmux attach -t $SESSION"
    echo "To exit: Press Ctrl+B, then D (or just close terminal)"

  elif command -v screen &> /dev/null; then
    echo "Detected Linux/macOS environment"
    echo "Launching with GNU Screen (5 split panes)..."
    echo ""

    SESSION="booking-monitor"

    # Kill existing session if it exists
    screen -S $SESSION -X quit 2>/dev/null || true
    sleep 1

    # Create new session and launch all scripts
    screen -dmS $SESSION bash -c "cd $PROJECT_ROOT && bash scripts/watch-logs.sh"
    screen -S $SESSION -X split -h
    screen -S $SESSION -X focus right
    screen -S $SESSION -X send-keys "cd $PROJECT_ROOT && bash scripts/watch-bookings.sh" Enter

    screen -S $SESSION -X split -h
    screen -S $SESSION -X focus right
    screen -S $SESSION -X send-keys "cd $PROJECT_ROOT && bash scripts/watch-events.sh" Enter

    screen -S $SESSION -X split -h
    screen -S $SESSION -X focus right
    screen -S $SESSION -X send-keys "cd $PROJECT_ROOT && bash scripts/watch-sqs.sh" Enter

    screen -S $SESSION -X split -h
    screen -S $SESSION -X focus right
    screen -S $SESSION -X send-keys "cd $PROJECT_ROOT && bash scripts/watch-s3.sh" Enter

    echo "✓ Launched GNU Screen session: $SESSION"
    echo ""
    echo "To view: screen -r $SESSION"
    echo "To exit: Press Ctrl+A, then D (or type 'exit')"

  else
    echo "Detected Linux/macOS environment"
    echo "Launching all 5 monitors in background..."
    echo ""

    # Create a temp directory for log files
    LOG_DIR="/tmp/booking-monitor-$$"
    mkdir -p "$LOG_DIR"

    # Launch all 5 scripts in background
    echo "Starting monitors..."
    (cd "$PROJECT_ROOT" && bash scripts/watch-logs.sh > "$LOG_DIR/logs.txt" 2>&1) &
    echo "  ✓ watch-logs.sh"

    (cd "$PROJECT_ROOT" && bash scripts/watch-bookings.sh > "$LOG_DIR/bookings.txt" 2>&1) &
    echo "  ✓ watch-bookings.sh"

    (cd "$PROJECT_ROOT" && bash scripts/watch-events.sh > "$LOG_DIR/events.txt" 2>&1) &
    echo "  ✓ watch-events.sh"

    (cd "$PROJECT_ROOT" && bash scripts/watch-sqs.sh > "$LOG_DIR/sqs.txt" 2>&1) &
    echo "  ✓ watch-sqs.sh"

    (cd "$PROJECT_ROOT" && bash scripts/watch-s3.sh > "$LOG_DIR/s3.txt" 2>&1) &
    echo "  ✓ watch-s3.sh"

    echo ""
    echo "✓ All 5 monitors launched in background"
    echo ""
    echo "To view output:"
    echo "  tail -f $LOG_DIR/logs.txt       # CloudWatch Logs"
    echo "  tail -f $LOG_DIR/bookings.txt   # DynamoDB Bookings"
    echo "  tail -f $LOG_DIR/events.txt     # DynamoDB Events"
    echo "  tail -f $LOG_DIR/sqs.txt        # SQS Queue"
    echo "  tail -f $LOG_DIR/s3.txt         # S3 Buckets"
    echo ""
    echo "To stop all monitors:"
    echo "  pkill -f 'bash scripts/watch-'"
    echo ""
  fi
else
  echo "Unknown OS: $OSTYPE"
  echo ""
  echo "Launch these 5 commands in separate terminals:"
  echo ""
  echo "  bash $SCRIPT_DIR/watch-logs.sh"
  echo "  bash $SCRIPT_DIR/watch-bookings.sh"
  echo "  bash $SCRIPT_DIR/watch-events.sh"
  echo "  bash $SCRIPT_DIR/watch-sqs.sh"
  echo "  bash $SCRIPT_DIR/watch-s3.sh"
fi

echo ""
print_header "Setup Complete"
echo ""
echo "Monitors are now running!"
echo ""
echo "Next steps:"
echo "  1. Open another terminal"
echo "  2. Run: cd frontend && npm start"
echo "  3. Go to: http://localhost:3000"
echo "  4. Login with: demo@example.com / Demo@123456"
echo "  5. Book an event"
echo "  6. Watch all 5 monitors in real-time!"
echo ""
