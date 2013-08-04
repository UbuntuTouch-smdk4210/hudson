cd $WORKSPACE

git clone git://github.com/UbuntuTouch-smdk4210/hudson.git

cd hudson
## Get rid of possible local changes
git reset --hard
git pull -s resolve

exec ./build.sh