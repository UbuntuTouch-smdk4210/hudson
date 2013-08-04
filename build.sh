#!/usr/bin/env bash

function check_result {
  if [ "0" -ne "$?" ]
  then
    (repo forall -c "git reset --hard") >/dev/null
    rm -f .repo/local_manifests/dyn-*.xml
    rm -f .repo/local_manifests/roomservice.xml
    echo $1
    exit 1
  fi
}

date=$(date +"%Y%m%d")
date1=$(date +"%m-%d")

if [ -z "$WORKSPACE" ]
then
echo WORKSPACE not specified
  exit 1
fi

if [ -z "$BRANCH" ]
then
echo BRANCH not specified
  exit 1
fi

if [ -z "$SYNC" ]
then
echo SYNC not sepecifed
  exit 1
fi

if [ -z "$DEVICE" ]
then
echo SYNC not sepecifed
  exit 1
fi

if [ -z "$CLEAN" ]
then
echo SYNC not sepecifed
  exit 1
fi

# colorization fix in Jenkins
export CL_RED="\"\033[31m\""
export CL_GRN="\"\033[32m\""
export CL_YLW="\"\033[33m\""
export CL_BLU="\"\033[34m\""
export CL_MAG="\"\033[35m\""
export CL_CYN="\"\033[36m\""
export CL_RST="\"\033[0m\""

cd $WORKSPACE
rm -rf archive
mkdir -p archive
export BUILD_NO=$BUILD_NUMBER
unset BUILD_NUMBER

export PATH=~/bin:$PATH

export USE_CCACHE=1
export CCACHE_NLEVELS=4
export BUILD_WITH_COLORS=0

mkdir -p $BRANCH
cd $BRANCH

if [ "$SYNC" = "yes" ]
then

rm -rf .repo/manifests*
rm -f .repo/local_manifests/roomservice.xml
cd $WORKSPACE

mkdir -p .repo/local_manifests
rm -f .repo/local_manifest.xml
cp /home/jenkins/ubuntutouch/build/$BRANCH/roomservice.xml $WORKSPACE/$BRANCH/.repo/local_manifests/roomservice.xml

phablet-dev-bootstrap -c $BRANCH
check_result "repo init failed."

/home/jenkins/ubuntutouch/bzr-platform-api.sh pull

cd $BRANCH

else
echo "Start withouth syncing"
fi

export CCACHE_DIR=~/.ut_ccache

. build/envsetup.sh

LAST_CLEAN=0
if [ -f .clean ]
then
LAST_CLEAN=$(date -r .clean +%s)
fi
TIME_SINCE_LAST_CLEAN=$(expr $(date +%s) - $LAST_CLEAN)
# convert this to hours
TIME_SINCE_LAST_CLEAN=$(expr $TIME_SINCE_LAST_CLEAN / 60 / 60)
if [ $TIME_SINCE_LAST_CLEAN -gt "24" -o $CLEAN = "true" ]
then
echo "Cleaning!"
  touch .clean
  make clobber
else
echo "Skipping clean: $TIME_SINCE_LAST_CLEAN hours since last clean."
fi

brunch $DEVICE

cp $OUT/cm-10.1-$date-UNOFFICIAL-$DEVICE.zip /var/www/vhosts/gerrett84.de/roms/$DEVICE/ubuntu/$BRANCH/$BUILD_STAT/saucy-preinstalled-armel-$DEVICE_$date1.zip

cd /var/www/vhosts/gerrett84.de/roms/$DEVICE/ubuntu/$BRANCH/$BUILD_STAT/

md5sum "saucy-preinstalled-armel-$DEVICE_date1.zip" > "saucy-preinstalled-armel-$DEVICE_$date1.zip.md5sum"

echo "Remove builds older than 5 days"
find /var/www/vhosts/gerrett84.de/roms/$DEVICE/ubuntu/$BRANCH/$BUILD_STAT/* -mtime +5 -exec rm {} \;
date

echo "Finished"