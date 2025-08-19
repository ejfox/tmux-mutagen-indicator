#!/usr/bin/env bash

set -e

ICON_SYNCED="✓"
ICON_SYNCING="⟳"
ICON_ERROR="✗"
ICON_PAUSED="⏸"
ICON_UNKNOWN="?"

SHOW_DETAILS="${MUTAGEN_TMUX_SHOW_DETAILS:-0}"
SHOW_NAME="${MUTAGEN_TMUX_SHOW_NAME:-0}"
SHOW_STATUS="${MUTAGEN_TMUX_SHOW_STATUS:-1}"
OUTPUT_FORMAT="${MUTAGEN_OUTPUT_FORMAT:-text}"

COLOR_SYNCED="${MUTAGEN_COLOR_SYNCED:-0xff9dd274}"
COLOR_SYNCING="${MUTAGEN_COLOR_SYNCING:-0xffeed49f}"
COLOR_ERROR="${MUTAGEN_COLOR_ERROR:-0xffed8796}"
COLOR_PAUSED="${MUTAGEN_COLOR_PAUSED:-0xffa6da95}"
COLOR_UNKNOWN="${MUTAGEN_COLOR_UNKNOWN:-0xff939ab7}"

parse_mutagen_status() {
    local output
    output=$(mutagen sync list 2>/dev/null || echo "")
    
    if [ -z "$output" ]; then
        echo "${ICON_UNKNOWN} No sessions"
        return
    fi
    
    local session_count=0
    local synced_count=0
    local syncing_count=0
    local error_count=0
    local paused_count=0
    local current_session=""
    local current_status=""
    local sessions=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^Identifier: ]]; then
            current_session="${line#Identifier: }"
            session_count=$((session_count + 1))
        elif [[ "$line" =~ ^Status: ]]; then
            current_status="${line#Status: }"
            current_status=$(echo "$current_status" | xargs)
            
            case "$current_status" in
                *"Watching for changes"*)
                    synced_count=$((synced_count + 1))
                    sessions+=("${ICON_SYNCED}")
                    ;;
                *"Scanning"*|*"Staging"*|*"Transitioning"*|*"Reconciling"*)
                    syncing_count=$((syncing_count + 1))
                    sessions+=("${ICON_SYNCING}")
                    ;;
                *"Paused"*)
                    paused_count=$((paused_count + 1))
                    sessions+=("${ICON_PAUSED}")
                    ;;
                *"Problem"*|*"Error"*|*"Halted"*)
                    error_count=$((error_count + 1))
                    sessions+=("${ICON_ERROR}")
                    ;;
                *)
                    sessions+=("${ICON_UNKNOWN}")
                    ;;
            esac
        fi
    done <<< "$output"
    
    if [ "$session_count" -eq 0 ]; then
        echo "${ICON_UNKNOWN} No sessions"
        return
    fi
    
    local status_string=""
    
    if [ "$SHOW_DETAILS" -eq 1 ]; then
        status_string="${sessions[*]}"
    else
        if [ "$error_count" -gt 0 ]; then
            status_string="${ICON_ERROR}"
        elif [ "$syncing_count" -gt 0 ]; then
            status_string="${ICON_SYNCING}"
        elif [ "$paused_count" -gt 0 ]; then
            status_string="${ICON_PAUSED}"
        elif [ "$synced_count" -eq "$session_count" ]; then
            status_string="${ICON_SYNCED}"
        else
            status_string="${ICON_UNKNOWN}"
        fi
    fi
    
    if [ "$SHOW_STATUS" -eq 1 ]; then
        if [ "$session_count" -gt 0 ]; then
            status_string="${status_string} ${session_count}"
        fi
    fi
    
    echo "$status_string"
}

get_primary_color() {
    local synced_count=$1
    local syncing_count=$2
    local error_count=$3
    local paused_count=$4
    local session_count=$5
    
    if [ "$error_count" -gt 0 ]; then
        echo "$COLOR_ERROR"
    elif [ "$syncing_count" -gt 0 ]; then
        echo "$COLOR_SYNCING"
    elif [ "$paused_count" -gt 0 ]; then
        echo "$COLOR_PAUSED"
    elif [ "$synced_count" -eq "$session_count" ] && [ "$session_count" -gt 0 ]; then
        echo "$COLOR_SYNCED"
    else
        echo "$COLOR_UNKNOWN"
    fi
}

output_sketchybar() {
    local output
    output=$(mutagen sync list 2>/dev/null || echo "")
    
    if [ -z "$output" ]; then
        echo "{\"text\":\"${ICON_UNKNOWN}\",\"tooltip\":\"No Mutagen sessions\",\"color\":\"$COLOR_UNKNOWN\"}"
        return
    fi
    
    local session_count=0
    local synced_count=0
    local syncing_count=0
    local error_count=0
    local paused_count=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^Identifier: ]]; then
            session_count=$((session_count + 1))
        elif [[ "$line" =~ ^Status: ]]; then
            local current_status="${line#Status: }"
            current_status=$(echo "$current_status" | xargs)
            
            case "$current_status" in
                *"Watching for changes"*)
                    synced_count=$((synced_count + 1))
                    ;;
                *"Scanning"*|*"Staging"*|*"Transitioning"*|*"Reconciling"*)
                    syncing_count=$((syncing_count + 1))
                    ;;
                *"Paused"*)
                    paused_count=$((paused_count + 1))
                    ;;
                *"Problem"*|*"Error"*|*"Halted"*)
                    error_count=$((error_count + 1))
                    ;;
            esac
        fi
    done <<< "$output"
    
    if [ "$session_count" -eq 0 ]; then
        echo "{\"text\":\"${ICON_UNKNOWN}\",\"tooltip\":\"No Mutagen sessions\",\"color\":\"$COLOR_UNKNOWN\"}"
        return
    fi
    
    local text=""
    local tooltip="Mutagen Sessions: $session_count"
    local color
    color=$(get_primary_color "$synced_count" "$syncing_count" "$error_count" "$paused_count" "$session_count")
    
    if [ "$error_count" -gt 0 ]; then
        text="${ICON_ERROR}"
        tooltip="$tooltip | Errors: $error_count"
    elif [ "$syncing_count" -gt 0 ]; then
        text="${ICON_SYNCING}"
        tooltip="$tooltip | Syncing: $syncing_count"
    elif [ "$paused_count" -gt 0 ]; then
        text="${ICON_PAUSED}"
        tooltip="$tooltip | Paused: $paused_count"
    elif [ "$synced_count" -eq "$session_count" ]; then
        text="${ICON_SYNCED}"
        tooltip="$tooltip | All synced"
    else
        text="${ICON_UNKNOWN}"
        tooltip="$tooltip | Status unknown"
    fi
    
    if [ "$SHOW_STATUS" -eq 1 ] && [ "$session_count" -gt 1 ]; then
        text="$text $session_count"
    fi
    
    echo "{\"text\":\"$text\",\"tooltip\":\"$tooltip\",\"color\":\"$color\"}"
}

main() {
    if [ "$OUTPUT_FORMAT" = "sketchybar" ]; then
        output_sketchybar
    else
        parse_mutagen_status
    fi
}

main "$@"