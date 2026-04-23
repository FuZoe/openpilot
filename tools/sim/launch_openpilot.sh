#!/usr/bin/env bash

export PASSIVE="0"
export NOBOARD="1"
export SIMULATION="1"
export SKIP_FW_QUERY="1"
export FINGERPRINT="HONDA_CIVIC_2022"
export TINYGRAD_DEBUG=0

if [[ -n "$CI" ]]; then
  # CI: run full stack (loggerd, encoderd, ui, soundd) so logs/cameras are
  # saved as artifacts.  Only block processes that need real hardware.
  export BLOCK="${BLOCK},camerad,stream_encoderd,micd,logmessaged,manage_athenad"
  # Provide a dummy PulseAudio sink so soundd can open an audio stream
  pulseaudio --check 2>/dev/null || pulseaudio --start --daemonize --exit-idle-time=-1 \
    --load="module-null-sink sink_name=ci_null" 2>/dev/null || true
elif [[ -n "$RECORD" ]]; then
  export BLOCK="${BLOCK},camerad,stream_encoderd,micd,logmessaged,manage_athenad,soundd"
else
  export BLOCK="${BLOCK},camerad,loggerd,encoderd,stream_encoderd,micd,logmessaged,manage_athenad,soundd"
fi

python3 -c "from openpilot.selfdrive.test.helpers import set_params_enabled; set_params_enabled()"

SCRIPT_DIR=$(dirname "$0")
OPENPILOT_DIR=$SCRIPT_DIR/../../

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $OPENPILOT_DIR/system/manager && exec ./manager.py
