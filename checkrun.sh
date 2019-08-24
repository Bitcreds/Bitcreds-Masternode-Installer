#!/bin/bash
# checkrun.sh
# Make sure credits is always running.
# Add the following to the crontab (i.e. crontab -e)
# */5 * * * * ~/credits-auto/checkrun.sh

if ps -A | grep creditsd > /dev/null
then
  exit
else
  creditsd &
fi
