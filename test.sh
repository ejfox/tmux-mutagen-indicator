#!/usr/bin/env bash

echo "Testing tmux-mutagen-indicator..."

echo -e "\n1. Test with no sessions:"
./mutagen-indicator.sh

echo -e "\n2. Test with SHOW_DETAILS enabled:"
MUTAGEN_TMUX_SHOW_DETAILS=1 ./mutagen-indicator.sh

echo -e "\n3. Test with SHOW_STATUS disabled:"
MUTAGEN_TMUX_SHOW_STATUS=0 ./mutagen-indicator.sh

echo -e "\n4. Test Sketchybar output:"
MUTAGEN_OUTPUT_FORMAT=sketchybar ./mutagen-indicator.sh

echo -e "\n5. Test Sketchybar with custom colors:"
MUTAGEN_OUTPUT_FORMAT=sketchybar MUTAGEN_COLOR_UNKNOWN=0xffff00ff ./mutagen-indicator.sh

echo -e "\nTo test with actual Mutagen sessions:"
echo "  1. Create a Mutagen sync session"
echo "  2. Run: ./mutagen-indicator.sh"
echo "  3. For tmux: set -g status-right '#($PWD/mutagen-indicator.sh)'"
echo "  4. For Sketchybar: copy sketchybar-plugin.sh to ~/.config/sketchybar/plugins/"

echo -e "\nDone!"