#!/bin/bash
# --- CONFIGURATION ---
STATE_FILE="/tmp/niri_mon_data"
SIG_FILE="/tmp/niri_mon_signature"
NOTIFY_DURATION=1000

get_sig() { cat /sys/class/drm/*/status; }

check_and_refresh() {
    [[ "$(get_sig)" != "$(cat "$SIG_FILE" 2>/dev/null)" ]] && parse_monitors
}

show_active_notify() {
    local active_ids=",$1,"
    mapfile -t CACHED_MONS < "$STATE_FILE"
    for i in "${!CACHED_MONS[@]}"; do
        USER_IDX=$((i+1))
        if [[ "$active_ids" == *",$USER_IDX,"* ]]; then
            IFS='|' read -r NAME DESC <<< "${CACHED_MONS[$i]}"
            notify-send -t $NOTIFY_DURATION "Activated [$USER_IDX]" "$NAME | $DESC"
        fi
    done
}

show_all_notify() {
    check_and_refresh
    mapfile -t CACHED_MONS < "$STATE_FILE"
    for i in "${!CACHED_MONS[@]}"; do
        IFS='|' read -r NAME DESC <<< "${CACHED_MONS[$i]}"
        notify-send -t $NOTIFY_DURATION "Display [$((i+1))]" "$NAME | $DESC"
    done
}

parse_monitors() {
    MON_JSON=$(niri msg -j outputs)
    INT_NAME=$(echo "$MON_JSON" | jq -r 'to_entries[] | select(.key | startswith("eDP")).key' | head -n1)
    [ -z "$INT_NAME" ] && INT_NAME=$(echo "$MON_JSON" | jq -r 'keys[0]')
    INT_DESC=$(echo "$MON_JSON" | jq -r ".\"$INT_NAME\".make + \" \" + .\"$INT_NAME\".model")
    EXT_DATA=$(echo "$MON_JSON" | jq -r "to_entries[] | select(.key != \"$INT_NAME\") | .key + \"|\" + .value.make + \" \" + .value.model" | sort)
    echo "$INT_NAME|$INT_DESC" > "$STATE_FILE"
    [ -n "$EXT_DATA" ] && echo "$EXT_DATA" >> "$STATE_FILE"
    get_sig > "$SIG_FILE"
}

apply_indices() {
    check_and_refresh
    mapfile -t CACHED_MONS < "$STATE_FILE"
    INPUT_IDS=",$1,"
    for i in "${!CACHED_MONS[@]}"; do
        NAME=$(echo "${CACHED_MONS[$i]}" | cut -d'|' -f1)
        USER_IDX=$((i+1))
        if [[ "$INPUT_IDS" == *",$USER_IDX,"* ]]; then
            niri msg output "$NAME" on
        else
            niri msg output "$NAME" off
        fi
    done
    show_active_notify "$1"
}

case $1 in
    --init) parse_monitors ;;
    --set)  apply_indices "$2" ;;
    --list) show_all_notify ;;
esac
