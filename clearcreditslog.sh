#!/bin/bash
# clearcreditslog.sh
# Clear debug.log every other day
# Add the following to the crontab (i.e. crontab -e)
# 0 0 */2 * * ~/credits-auto/credits/clearcreditslog.sh

/bin/date > ~/.credits/debug.log
