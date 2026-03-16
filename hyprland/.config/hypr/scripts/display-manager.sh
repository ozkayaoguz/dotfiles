#!/bin/bash
# --- CONFIGURATION ---
STATE_FILE="/tmp/hypr_mon_data"
SIG_FILE="/tmp/hypr_mon_signature"

# Check physical connection status (fastest check)
get_sig() { cat /sys/class/drm/*/status; }

show_active_notify() {
    local active_ids=",$1,"
    mapfile -t ALL_MONS < "$STATE_FILE"
    MON_INFO=$(hyprctl monitors all -j)
    
    for i in "${!ALL_MONS[@]}"; do
        USER_IDX=$((i+1))
        if [[ "$active_ids" == *",$USER_IDX,"* ]]; then
            NAME=$(echo "${ALL_MONS[$i]}" | xargs)
            DESC=$(echo "$MON_INFO" | jq -r ".[] | select(.name == \"$NAME\").model // \"Display\"")
            notify-send -t 3000 -i display "Activated [$USER_IDX]" "$NAME | $DESC"
        fi
    done
}

show_all_notify() {
    mapfile -t ALL_MONS < "$STATE_FILE"
    MON_INFO=$(hyprctl monitors all -j)
    for i in "${!ALL_MONS[@]}"; do
        NAME=$(echo "${ALL_MONS[$i]}" | xargs)
        DESC=$(echo "$MON_INFO" | jq -r ".[] | select(.name == \"$NAME\").model // \"Display\"")
        notify-send -t 4000 -i display "Display [$((i+1))]" "$NAME | $DESC"
    done
}

parse_monitors() {
    MONS=$(hyprctl monitors all -j)
    # Primary: eDP (Laptop), fallback to first available (Desktop)
    INT=$(echo "$MONS" | jq -r '.[] | select(.name | startswith("eDP")).name')
    [ -z "$INT" ] && INT=$(echo "$MONS" | jq -r '..name')
    # Secondary: All others sorted
    EXTS=$(echo "$MONS" | jq -r ".[] | select(.name != \"$INT\").name" | sort)
    
    echo "$INT" > "$STATE_FILE"
    [ -n "$EXTS" ] && echo "$EXTS" >> "$STATE_FILE"
    get_sig > "$SIG_FILE"
}

apply_indices() {
    [[ "$(get_sig)" != "$(cat "$SIG_FILE" 2>/dev/null)" ]] && parse_monitors
    mapfile -t MONS < "$STATE_FILE"
    INPUT_IDS=",$1,"

    for i in "${!MONS[@]}"; do
        NAME=$(echo "${MONS[$i]}" | xargs | tr -d '\r\n')
        [ -z "$NAME" ] && continue
        USER_IDX=$((i+1))
        
        if [[ "$INPUT_IDS" == *",$USER_IDX,"* ]]; then
            hyprctl keyword monitor "$NAME,preferred,auto,1"
        else
            hyprctl keyword monitor "$NAME,disable"
        fi
    done
    show_active_notify "$1"
}

case $1 in
    --init) parse_monitors ;;
    --set)  apply_indices "$2" ;;
    --list) parse_monitors; show_all_notify ;;
esac

