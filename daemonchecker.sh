#!/bin/bash
# daemonchecker.sh
# Make sure the daemon is not stuck.
# Add the following to the crontab (i.e. crontab -e)
# */30 * * * * ~/credits-auto/daemonchecker.sh

previousBlock=$(cat ~/credits-auto/blockcount)
currentBlock=$(credits-cli getblockcount)

credits-cli getblockcount > ~/credits-auto/blockcount

if [ "$previousBlock" == "$currentBlock" ]; then
  credits-cli stop
  sleep 10
  creditsd --daemon
fi
