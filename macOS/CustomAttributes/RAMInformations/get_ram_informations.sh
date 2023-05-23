#!/bin/bash
#set -x

ram=$(system_profiler SPHardwareDataType | grep "  Memory:" | sed 's/.*Memory: //' | sed 's/GB.*//')
echo $ram
