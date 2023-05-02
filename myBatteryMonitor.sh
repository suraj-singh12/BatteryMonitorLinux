#!/bin/bash

# Infinite loop to check battery percentage
while true; do
    # Get the battery percentage as an integer
    battery_percentage=$(upower -i $(upower -e | grep BAT) | awk '/percentage:/ {sub(/%/, ""); printf "%d", $2}')
    # Get the charging status of the battery
    charging=$(upower -i $(upower -e | grep BAT) | grep -q "state:\s*charging" && echo true || echo false)
    
    # Check if battery percentage is below 10 and "not charging"
    if [ "$battery_percentage" -lt 10 ] && ! $charging; then
        # Battery is critically low
        echo -e "\e[31mBattery is critically low!\e[0m"
        echo -e "\e[31mShutting down the system in 1 min if not plugged in!\e[0m"

        # Beep alert
        play -q beep.wav repeat 1 > /dev/null 2>&1
        
        # Wait for 60 seconds for the user to close everything or plug in charging
        seconds_left=60
        while [ $seconds_left -gt 0 ]; do
            # Clear the line and print the remaining seconds
            tput cuu1; tput el; echo -ne "\rShutting down in $seconds_left seconds"
            
            # Beep when last 10 seconds are remaining
            if [ $seconds_left -le 10 ]; then
                play -q beep_short.wav > /dev/null 2>&1
            fi
            
            # Wait for 1 second
            sleep 1
            
            # Decrement the seconds left
            seconds_left=$((seconds_left - 1))
        done

        # Shutdown the system
        shutdown now
    fi
    
    # Check if battery percentage is greater than 95 and "charging"
    if [ "$battery_percentage" -gt 95 ] && $charging; then
        # Battery is fully charged
        echo -e "\e[32mBattery is fully charged!\e[0m"
        # Beep alert
        play -q beep.wav > /dev/null 2>&1
    fi

    # Wait for 10 seconds before checking again
    sleep 10
done

