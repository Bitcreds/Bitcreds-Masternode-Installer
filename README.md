# credits-AUTO MASTERNODE INSTALLER!
### Bash installer for credits masternode on the latest stable Ubuntu 18.04 LTS version.

#### This shell script comes with 3 cronjobs: 
1. Make sure the daemon is always running: `checkrun.sh`
2. Make sure the daemon is never stuck: `daemonchecker.sh`
3. Clear the log file every other day to keep your machine alive : `clearcreditslog.sh`

#### Login to your vps as root, download the install.sh file and then run it:
```
wget --no-check-certificate https://raw.githubusercontent.com/razerrazer/credits-AUTO/master/credits-auto.sh
bash ./credits-auto.sh
```

#### Run the qt wallet, go to MASTERNODE tab, click "Start Alias" at the bottom or right click on your masternode (before unlock your addresses under inputs.)

```
use "credits-cli masternode status" to see if your masternode is working properly.
1. "status": "Node just started, not yet acitvated" // This means that your masternode has been activated and you have to wait at least one hour to check if the status has been changed.
2. "status": "Masternode successfully started" // This means that your masternode is working and the masternode is successfully started.

examples when it's working : 
~/credits-auto# credits-cli masternode status
{
  "vin": "CTxIn(COutPoint(xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx, 0), scriptSig=)",
  "service": "xxx.xx.xx.xxx:31000",
  "payee": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "status": "Masternode successfully started"
}
```

#### PLEASE READ https://crds.co/documents/masternode-setup.pdf ####

## Donations are not required, but are appreciated
#CRDS CX9LCYhp2rEbmAi1Ur3LAXU1GLLLjk3qqU
#BTC 3BixhaziZbwY9HHgvFMBqbaZ5M2bPjhSCy
