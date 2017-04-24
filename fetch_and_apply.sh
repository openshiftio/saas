#!/bin/bash

TSTAMP=$(date +%Y%m%d_%H%M%S)
TPLDIR="dsaas-templates"
CONF="/home/`whoami`/.kube/config"

function git_prep {
    # should also check that the git master co is clean
    git checkout master
    git pull --rebase upstream master
}

function prep {
    git_prep

    TOK=$(cat ../osd-dsaas-token-`whoami`)
    oc login https://api.dsaas.openshift.com --token=${TOK}
    if [ $? -ne 0 ]; then echo "E: unable to login to openshift"; exit 2 ;fi

    oc project dsaas-production
    if [ $? -ne 0 ]; then echo "E: unable to get oc project"; exit 3 ;fi
}

function oc_apply {
    oc --config=${CONF} apply -f $1
}


# get some basics in place, no prep in prod deploy
if [ ! -e ~/.kube/cfg-dsaas ] ; then
    # this is a dev machine
    prep
else
    CONF="/home/`whoami`/.kube/cfg-dsaas"
fi

# lets clear this out to make sure we always have a 
# fresh set of templates, and nothing else left behind
rm -rf ${TPLDIR}; mkdir -p ${TPLDIR}

python saasherder/cli.py -D ${TPLDIR}/ -s dsaas-services/ pull
mkdir -p $TSTAMP
python saasherder/cli.py -D ${TPLDIR}/ -s dsaas-services/ \
       template --output-dir $TSTAMP tag

for f in `ls $TSTAMP/*`; do
    oc_apply $f
done

if [ $(find ${TSTAMP}/ -name \*.yaml | wc -l ) -lt 1 ]; then
    # if we didnt apply anything, dont keep the dir around
    rm -rf $TSTAMP
    echo "R: Nothing to apply"
fi
