#!/bin/sh
#set -x

# Returns the number of cycles of the device's battery.
echo $(system_profiler SPPowerDataType | grep "Cycle Count:" | sed 's/.*Cycle Count: //')
