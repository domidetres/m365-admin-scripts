#!/bin/bash

#set -x

############################################################################################
##
## Script to enable automatic App Store app updates (system-wide)
##
## macOS 27+ has no MDM/DDM key for "Automatic Updates" in the App Store. Users can still
## turn the checkbox off; run this script on a schedule (e.g. every 1 day) to re-apply it.
## Intune: run as root (not as signed-in user).
## Tested: macOS 27.2 (2026-10-30)
##
############################################################################################

## Define variables
appname="AppStoreAutoUpdate"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"
plist="/Library/Preferences/com.apple.commerce"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

# start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting $appname"
echo "############################################################"
echo "Writing log output to [$log]"
echo ""

echo " $(date) | Checking if App Store automatic updates are already enabled"

CurrentValue=$(defaults read $plist AutoUpdate 2>/dev/null)
echo " $(date) | Current AutoUpdate value: ${CurrentValue:-not set}"

if [[ "$CurrentValue" == "1" ]]
  then
  echo " $(date) | Change not required, AutoUpdate already enabled"
  exit 0
fi

# Enabling AutoUpdate
defaults write $plist AutoUpdate -bool true
if [ "$?" = "0" ]; then
   echo " $(date) | AutoUpdate changed from ${CurrentValue:-not set} to 1"
else
   echo " $(date) | Failed to enable AutoUpdate"
   exit 1
fi
