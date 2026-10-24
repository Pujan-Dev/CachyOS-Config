#!/usr/bin/env bash
# Shared helpers for waybar custom modules.

# wb_json <text> <class> <tooltip>   (tooltip newlines already escaped as \n)
wb_json() {
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$1" "$2" "$3"
}
