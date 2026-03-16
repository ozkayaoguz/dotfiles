#!/bin/bash
# --- CONFIGURATION ---
STATE_FILE="/tmp/hypr_mon_data"
SIG_FILE="/tmp/hypr_mon_signature"
NOTIFY_DURATION=1000

get_sig() { cat /sys/class/drm/*/status; }

# Centralized hardware change check
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
    MON_JSON=$(hyprctl monitors all -j)
    # Identify Internal (eDP)
    INT_NAME=$(echo "$MON_JSON" | jq -r '.[] | select(.name | startswith("eDP")).name')
    [ -z "$INT_NAME" ] && INT_NAME=$(echo "$MON_JSON" | jq -r '.[0].name')
    INT_DESC=$(echo "$MON_JSON" | jq -r ".[] | select(.name == \"$INT_NAME\").model")
    # Identify Externals (Sorted)
    EXT_DATA=$(echo "$MON_JSON" | jq -r ".[] | select(.name != \"$INT_NAME\") | .name + \"|\" + .model" | sort)
    # Save indexed data: NAME|MODEL
    echo "$INT_NAME|$INT_DESC" > "$STATE_FILE"
    [ -n "$EXT_DATA" ] && echo "$EXT_DATA" >> "$STATE_FILE"
    get_sig > "$SIG_FILE"
}

apply_indices() {
    check_and_refresh
    mapfile -t CACHED_MONS < "$STATE_FILE"
    
    # SAFETY CHECK: If requested index doesn't exist or no index provided, 
    # fallback to Index 1 (Primary) to prevent total black screen
    local REQUESTED_IDS="$1"
    local VALID_REQUEST=false
    
    for id in ${REQUESTED_IDS//,/ }; do
        if [ "$id" -le "${#CACHED_MONS[@]}" ] && [ "$id" -gt 0 ]; then
            VALID_REQUEST=true
        fi
    done

    # If the user tries to set an index that doesn't exist (like --set 2 when only 1 exists)
    # we force Index 1 to be active so the user isn't stuck with a black screen.
    if [ "$VALID_REQUEST" = false ]; then
        REQUESTED_IDS="1"
        notify-send -u critical "Display Manager" "Invalid Index: Falling back to Primary"
    fi

    INPUT_IDS=",$REQUESTED_IDS,"

    for i in "${!CACHED_MONS[@]}"; do
        # Extract only the NAME part for hyprctl command
        NAME=$(echo "${CACHED_MONS[$i]}" | cut -d'|' -f1)
        USER_IDX=$((i+1))
        
        if [[ "$INPUT_IDS" == *",$USER_IDX,"* ]]; then
            hyprctl keyword monitor "$NAME,preferred,auto,1"
        else
            hyprctl keyword monitor "$NAME,disable"
        fi
    done
    show_active_notify "$REQUESTED_IDS"
}

case $1 in
    --init) parse_monitors ;;
    --set)  apply_indices "$2" ;;
    --list) show_all_notify ;;
esac
