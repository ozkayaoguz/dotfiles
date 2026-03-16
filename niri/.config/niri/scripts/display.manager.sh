#!/bin/bash
# --- CONFIGURATION ---
STATE_FILE="/tmp/niri_mon_data"
SIG_FILE="/tmp/niri_mon_signature"

get_sig() { cat /sys/class/drm/*/status; }

show_active_notify() {
    local active_ids=",$1,"
    mapfile -t ALL_MONS < "$STATE_FILE"
    MON_INFO=$(niri msg -j outputs)
    for i in "${!ALL_MONS[@]}"; do
        USER_IDX=$((i+1))
        if [[ "$active_ids" == *",$USER_IDX,"* ]]; then
            NAME=$(echo "${ALL_MONS[$i]}" | xargs)
            MAKE=$(echo "$MON_INFO" | jq -r ".\"$NAME\".make // \"Unknown\"")
            MODEL=$(echo "$MON_INFO" | jq -r ".\"$NAME\".model // \"Display\"")
            notify-send -t 3000 -i display "Activated [$USER_IDX]" "$NAME | $MAKE $MODEL"
        fi
    done
}

show_all_notify() {
    mapfile -t ALL_MONS < "$STATE_FILE"
    MON_INFO=$(niri msg -j outputs)
    for i in "${!ALL_MONS[@]}"; do
        NAME=$(echo "${ALL_MONS[$i]}" | xargs)
        MAKE=$(echo "$MON_INFO" | jq -r ".\"$NAME\".make // \"Unknown\"")
        MODEL=$(echo "$MON_INFO" | jq -r ".\"$NAME\".model // \"Display\"")
        notify-send -t 4000 -i display "Display [$((i+1))]" "$NAME | $MAKE $MODEL"
    done
}

parse_monitors() {
    MON_JSON=$(niri msg -j outputs)
    # Get internal (eDP) first, then sort others
    INT=$(echo "$MON_JSON" | jq -r 'keys[] | select(startswith("eDP"))' | head -n1)
    [ -z "$INT" ] && INT=$(echo "$MON_JSON" | jq -r 'keys[0]')
    EXTS=$(echo "$MON_JSON" | jq -r "keys[] | select(. != \"$INT\")" | sort)
    
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
            # Ekranı AÇ
            niri msg output "$NAME" on
        else
            # Ekranı KAPAT
            niri msg output "$NAME" off
        fi
    done
    show_active_notify "$1"
}

case $1 in
    --init) parse_monitors ;;
    --set)  apply_indices "$2" ;;
    --list) parse_monitors; show_all_notify ;;
esac

