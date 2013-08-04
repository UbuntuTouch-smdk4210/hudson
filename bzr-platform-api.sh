#!/bin/bash

if [ -z "$BRANCH" ]
then
echo BRANCH is not set
exit 1
fi

if [ -z "$WORKSPACE" ]
then
echo WORKSPACE is not set
exit 1
fi

E_BADARGS=85
VAL_ARGS=( branch pull )

if [ $# -ne 1 ]
then
    echo "Bad number of arguments. Try one of the following:"
    echo "    $ $0 branch"
    echo "    $ $0 pull"
    exit $E_BADARGS
fi

VALID=false

for i in ${VAL_ARGS[*]}
do
    if [ "$1" = "$i" ]
    then
        VALID=true
    fi
done

if [ $VALID = false ]
then
    echo -e "Bad argument '$1'. Try one of the following:"
    echo "    $ $0 branch"
    echo "    $ $0 pull"
    exit $E_BADARGS
fi

if [ "$1" = "branch" ]
then
    echo "Branching lp:platform-api into $WORKSPACE/$BRANCH/ubuntu/platform-api"
    bzr branch lp:platform-api $WORKSPACE/$BRANCH/ubuntu/platform-api
else
    cd $WORKSPACE/$BRANCH/ubuntu/platform-api
    bzr pull
    cd ../..
fi