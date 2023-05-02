#!/bin/bash

# Infinite loop to check battery percentage
while true; do
    # Get the battery percentage as an integer
    battery_percentage=$(upower -i $(upower -e | grep BAT) | awk '/percentage:/ {sub(/%/, ""); printf "%d", $2}')

    # Check if battery percentage is below 30
    if [ "$battery_percentage" -lt 10 ]; then
        # Battery is critically low
        echo -e "\e[31mBattery is critically low!\e[0m"
        echo -e "\e[31mShutting down the system in 1 min if not plugged in!\e[0m"

        # Beep (assuming you have the "sox" command installed)
        playu -q beep.wav repeat 1 > /dev/null 2>&1
        
        # Wait for 60 seconds for the user to close everything or plug in charging
        seconds_left=60
        while [ $seconds_left -gt 0 ]; do
            # Clear the line and print the remaining seconds
            tput cuu1; tput el; echo -ne "\rShutting down in $seconds_left seconds"
            
            # Wait for 1 second
            sleep 1
            
            # Decrement the seconds left
            seconds_left=$((seconds_left - 1))
        done

        # Shutdown the system
        shutdown now
    fi

    # Wait for 10 seconds before checking again
    sleep 10
done

