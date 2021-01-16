#!/bin/sh

#
# Updated ein Debian-System und leg vorher ZFS-Snapshots an
#

LETZTESUPDATE=vorletztesUpdate
DIESESUPDATE=letztesUpdate
DATUM=`date +%Y%m%d`

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ ! -z $1 ]; then
    ADD="-$1"
fi

LASTSNAPSHOTS=`zfs list -t snap | grep $LETZTESUPDATE`
CURRENTSNAPSHOTS=`zfs list -t snap | grep $DIESESUPDATE`

if [ -z "$LASTSNAPSHOTS" ]; then
    echo "${RED}Es existiert kein alter Snapshot mit Namen $LETZTESUPDATE${NC}"
else
    echo "${BLUE}Entferne alte Snapshots mit Titel \"$LETZTESUPDATE\"${NC}"
    zfs list -H -t snap | grep $LETZTESUPDATE | awk '{print $1}' | xargs -I {} zfs destroy {}
fi

if [ -z "$CURRENTSNAPSHOTS" ]; then
    echo "${RED}Es existieren keine Snaphots mit dem Namen \"$DIESESUPDATE\"${NC}"
else
    echo "${BLUE}Benenne letzte Snapshots von \"$DIESESUPDATE\" in \"$LETZTESUPDATE\" um${NC}"
    zfs list -H -t snap | grep $DIESESUPDATE | awk '{print $1}'  | xargs -I {} zfs rename {} @$LETZTESUPDATE
fi

echo "${BLUE}Lege neue Snapshots mit dem Titel \"$DIESESUPDATE\" an${NC}"
zfs snap -r rpool@$DIESESUPDATE
zfs snap -r bpool@$DIESESUPDATE

echo "${BLUE}Update des Systems durchführen${NC}"
echo "${BLUE}Update der Repositories${NC}"
apt update
echo "${BLUE}Update der Pakete${NC}"
apt upgrade
echo "${BLUE}Update der Distri-Pakete${NC}"
apt dist-upgrade
echo "${BLUE}Entfernen alter Pakete${NC}"
apt autoremove
echo "${BLUE}Update von System-Flatpaks${NC}"
flatpak update
