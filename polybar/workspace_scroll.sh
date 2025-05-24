#!/bin/bash

# Get the focused monitor
get_focused_monitor() {
    focused_workspace=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true)')
    echo $(echo "$focused_workspace" | jq -r '.output')
}

# Format and output workspaces for polybar
format_workspaces() {
    # Get all workspaces
    workspaces=$(i3-msg -t get_workspaces)
    
    # Get focused workspace
    focused=$(echo "$workspaces" | jq '.[] | select(.focused==true) | .name' | tr -d '"')
    
    # Get urgent workspaces
    urgent_workspaces=$(echo "$workspaces" | jq '.[] | select(.urgent==true) | .name' | tr -d '"')
    
    # Get all workspace names
    all_workspaces=$(echo "$workspaces" | jq '.[].name' | tr -d '"' | sort -n)
    
    output=""
    
    # Format each workspace
    for workspace in $all_workspaces; do
        if [[ "$workspace" == "$focused" ]]; then
            # Active workspace
            output+=" %{F#F00}$workspace%{F-} "
        elif [[ "$urgent_workspaces" == *"$workspace"* ]]; then
            # Urgent workspace
            output+=" %{F#F00 B${colors.alert}}$workspace%{F- B-} "
        else
            # Check if workspace is occupied
            is_occupied=$(echo "$workspaces" | jq ".[] | select(.name==\"$workspace\") | .visible" 2>/dev/null)
            if [[ "$is_occupied" == "true" ]]; then
                # Occupied workspace
                output+=" %{F#F00}$workspace%{F-} "
            else
                # Empty workspace
                output+=" %{F#59F}$workspace%{F-} "
            fi
        fi
    done
    
    echo "$output"
}

# Handle scrolling to next/prev workspace on current monitor
handle_scroll() {
    direction=$1
    current_monitor=$(get_focused_monitor)
    current_workspace=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true) | .name' | tr -d '"')
    
    # Get all workspaces on the current monitor
    monitor_workspaces=($(i3-msg -t get_workspaces | jq ".[] | select(.output==\"$current_monitor\") | .name" | sort -n | tr -d '"'))
    
    # Find current workspace index in the array
    current_index=-1
    for i in "${!monitor_workspaces[@]}"; do
        if [[ "${monitor_workspaces[$i]}" == "$current_workspace" ]]; then
            current_index=$i
            break
        fi
    done
    
    # If we found the current workspace
    if [[ $current_index -ne -1 ]]; then
        # Calculate next workspace based on direction
        if [[ "$direction" == "up" ]]; then
            next_index=$(( (current_index + 1) % ${#monitor_workspaces[@]} ))
        else
            next_index=$(( (current_index - 1 + ${#monitor_workspaces[@]}) % ${#monitor_workspaces[@]} ))
        fi
        
        # Switch to the next workspace
        i3-msg workspace "${monitor_workspaces[$next_index]}" >/dev/null
    fi
    
    # Output formatted workspaces
    format_workspaces
}

# Main function to output workspaces and handle events
if [[ "$1" == "scroll_up" ]]; then
    handle_scroll "up"
elif [[ "$1" == "scroll_down" ]]; then
    handle_scroll "down"
else
    # Initial output
    format_workspaces
    
    # Monitor for workspace changes
    i3-msg -t subscribe -m '["workspace"]' | while read -r line; do
        format_workspaces
    done
fi
