#!/bin/bash

MAX_SIZE=$((50 * 1024 * 1024))  # 50 MB in bytes
echo "🔎 Scanning for .wav files over 50MB..."

# Find oversized .wav files
large_wavs=$(find . -type f -iname "*.wav" ! -path "./.git/*" -size +${MAX_SIZE}c)

if [ -z "$large_wavs" ]; then
  echo "✅ No .wav files over 50MB found."
  exit 0
fi

# Display table
echo ""
echo "❌ The following .wav file(s) exceed 50MB:"
printf "%-80s %10s\n" "File" "Size (MB)"
printf "%-80s %10s\n" "----" "---------"

while IFS= read -r wav; do
  size_bytes=$(stat -c%s "$wav")
  size_mb=$(awk "BEGIN {printf \"%.2f\", $size_bytes/1024/1024}")
  printf "%-80s %10s\n" "$wav" "$size_mb"
done <<< "$large_wavs"

# Confirm before conversion
echo ""
read -p "🎧 Convert these .wav files to .mp3 now? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "❌ Conversion canceled."
  exit 1
fi

# Convert .wav to .mp3 (preserve directory structure)
echo ""
echo "🎶 Converting to .mp3..."
while IFS= read -r wav; do
  mp3="${wav%.wav}.mp3"
  dir=$(dirname "$mp3")
  mkdir -p "$dir"
  echo "Converting: $wav → $mp3"
  ffmpeg -y -i "$wav" -codec:a libmp3lame -qscale:a 2 "$mp3"
  
  # Optional: delete original WAV
  # rm "$wav"

done <<< "$large_wavs"

echo ""
echo "✅ Conversion complete."
