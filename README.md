# tmux-mutagen-indicator

A status bar indicator for Mutagen sync sessions, supporting both tmux and Sketchybar.

Inspiration: https://github.com/andrewmed/mutagenmon

## Features

- Shows real-time sync status of all Mutagen sessions
- Support for both tmux and Sketchybar
- Configurable display options and colors
- Simple icons for quick status overview
- Count display for multiple sessions
- JSON output for Sketchybar with tooltips and colors

## Installation

1. Clone this repository or download the script:
```bash
git clone https://github.com/ejfox/tmux-mutagen-indicator.git
cd tmux-mutagen-indicator
# OR download directly
curl -o ~/bin/mutagen-indicator.sh https://raw.githubusercontent.com/ejfox/tmux-mutagen-indicator/main/mutagen-indicator.sh
chmod +x ~/bin/mutagen-indicator.sh
```

2. Add to your tmux configuration (`~/.tmux.conf`):
```tmux
set -g status-right '#(~/bin/mutagen-indicator.sh) #[default]| %H:%M %d-%b-%y'
# OR if you cloned the repo
set -g status-right '#(/path/to/tmux-mutagen-indicator/mutagen-indicator.sh) #[default]| %H:%M %d-%b-%y'
```

3. Reload tmux configuration:
```bash
tmux source-file ~/.tmux.conf
```

### Sketchybar Setup

1. Copy the plugin to your Sketchybar plugins directory:
```bash
cp sketchybar-plugin.sh ~/.config/sketchybar/plugins/mutagen.sh
chmod +x ~/.config/sketchybar/plugins/mutagen.sh
```

2. Add the item to your Sketchybar configuration (`~/.config/sketchybar/sketchybarrc`):
```bash
sketchybar --add item mutagen right \
           --set mutagen update_freq=5 \
                         script="~/.config/sketchybar/plugins/mutagen.sh" \
                         icon="⟳" \
                         icon.font="SF Pro Display:Bold:14.0" \
                         label.font="SF Pro Display:Medium:14.0" \
                         background.corner_radius=5 \
                         background.height=24
```

3. Reload Sketchybar:
```bash
sketchybar --reload
```

## Configuration

Set these environment variables to customize the display:

### General Options
- `MUTAGEN_OUTPUT_FORMAT`: Output format ("text" or "sketchybar", default: "text")
- `MUTAGEN_TMUX_SHOW_DETAILS`: Show individual session icons (0 or 1, default: 0)
- `MUTAGEN_TMUX_SHOW_STATUS`: Show status counts (0 or 1, default: 1)
- `MUTAGEN_TMUX_SHOW_NAME`: Show session names (0 or 1, default: 0) [Future feature]

### Sketchybar Colors (Catppuccin theme)
- `MUTAGEN_COLOR_SYNCED`: Color for synced status (default: 0xff9dd274 - green)
- `MUTAGEN_COLOR_SYNCING`: Color for syncing status (default: 0xffeed49f - yellow)
- `MUTAGEN_COLOR_ERROR`: Color for error status (default: 0xffed8796 - red)
- `MUTAGEN_COLOR_PAUSED`: Color for paused status (default: 0xffa6da95 - light green)
- `MUTAGEN_COLOR_UNKNOWN`: Color for unknown status (default: 0xff939ab7 - gray)

### Examples

**tmux configuration** (`.tmux.conf`):
```tmux
setenv -g MUTAGEN_TMUX_SHOW_DETAILS 1
setenv -g MUTAGEN_TMUX_SHOW_STATUS 1
```

**Sketchybar with custom colors** (in plugin or rc file):
```bash
export MUTAGEN_OUTPUT_FORMAT="sketchybar"
export MUTAGEN_COLOR_SYNCED="0xff50fa7b"
export MUTAGEN_COLOR_ERROR="0xffff5555"
```

## Status Icons

- ✓ : Synced (watching for changes)
- ⟳ : Syncing (scanning/staging/transitioning)
- ⏸ : Paused
- ✗ : Error/Problem
- ? : Unknown status

## Usage

### Command Line
```bash
# Basic usage (text output)
./mutagen-indicator.sh

# Sketchybar JSON output
MUTAGEN_OUTPUT_FORMAT=sketchybar ./mutagen-indicator.sh

# Show detailed status
MUTAGEN_TMUX_SHOW_DETAILS=1 ./mutagen-indicator.sh
```

### Example Outputs

**Text mode (tmux):**
- `✓ 2` - 2 sessions, all synced
- `⟳ 1` - 1 session syncing
- `✗ 1` - 1 session with errors
- `? No sessions` - No active sessions

**JSON mode (Sketchybar):**
```json
{"text":"✓ 3","tooltip":"Mutagen Sessions: 3 | All synced","color":"0xff9dd274"}
```

## Testing

Run the included test script to verify functionality:
```bash
./test.sh
```

## Requirements

- [Mutagen](https://mutagen.io/) installed and configured
- tmux (for tmux integration)
- [Sketchybar](https://github.com/FelixKratz/SketchyBar) (for Sketchybar integration)
- bash

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see the code for details.
