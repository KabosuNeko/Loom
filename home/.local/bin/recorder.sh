#!/usr/bin/env bash

record() {
  OUTPUT_FILE="$HOME/Videos/screencast_$(date +%F_%H-%M-%S).mp4"

  if command -v nvidia-smi &> /dev/null; then
    ENCODER="-c:v h264_nvenc -preset p6 -cq 20"
  else
    ENCODER="-c:v libx264 -preset ultrafast -crf 20"
  fi

  AUDIO_SOURCE="$(pactl get-default-sink).monitor"

  ffmpeg -video_size 1920x1080 -framerate 60 -f x11grab -i :0.0 \
         -f pulse -i "$AUDIO_SOURCE" \
         $ENCODER -c:a aac -b:a 192k \
         "$OUTPUT_FILE" &> /dev/null &

  echo $! > /tmp/recpid

  (
    SECONDS=0
    while [[ -f /tmp/recpid ]]; do
      printf "^C10^ %02d:%02d^d^" $((SECONDS/60)) $((SECONDS%60)) > /tmp/rectime
      sleep 1
    done
  ) &

  notify-send -t 1500 -h string:bgcolor:#a3be8c "Recording Started" "Capturing screen and system audio."
}

end() {
  if [[ -f /tmp/recpid ]]; then
    kill -15 "$(cat /tmp/recpid)" 2>/dev/null
    rm -f /tmp/recpid
  fi

  rm -f /tmp/rectime

  notify-send -t 1500 -h string:bgcolor:#bf616a "Recording Ended" "Video saved successfully."
}

if [[ -f /tmp/recpid ]]; then
  end
else
  record
fi
