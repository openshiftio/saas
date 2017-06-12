#!/bin/bash

TSTAMP=$(date +%Y%m%d_%H%M%S)
TPLDIR="dsaas-templates"
CONF="/home/`whoami`/.kube/config"

SAAS_GROUPS="dsaas:dsaas-production bay:bayesian-preview keycloak:dsaas-keycloak"

function git_prep {
    # should also check that the git master co is clean
    git checkout master
    git pull --rebase upstream master
}

function prep {
    local PROJECT=$1
    git_prep

    TOK=$(cat ../osd-dsaas-token-`whoami`)
    oc login https://api.dsaas.openshift.com --token=${TOK}
    if [ $? -ne 0 ]; then echo "E: unable to login to openshift"; exit 2 ;fi

    oc project ${PROJECT}
    if [ $? -ne 0 ]; then echo "E: unable to get oc project ${PROJECT}"; exit 3 ;fi
}

function oc_apply {
    config=""
    [ -n "${CONF}" ] && config="--config=${CONF}"
    oc $config apply -f $1
}

function pull_tag {
    local GROUP=$1
    local PROCESSED_DIR=$2

    local TEMPLATE_DIR=${GROUP}-templates

    # lets clear this out to make sure we always have a
    # fresh set of templates, and nothing else left behind
    rm -rf ${TEMPLATE_DIR}; mkdir -p ${TEMPLATE_DIR}

    if [ -e /home/`whoami`/${GROUP}-gh-token-`whoami` ]; then GH_TOKEN=" --token "$(cat /home/`whoami`/${GROUP}-gh-token-`whoami`); fi

    python saasherder/cli.py -D ${TEMPLATE_DIR}/ -s ${GROUP}-services/ pull $GH_TOKEN

    python saasherder/cli.py -D ${TEMPLATE_DIR}/ -s ${GROUP}-services/ \
        template --output-dir ${PROCESSED_DIR} tag
}

for g in `echo ${SAAS_GROUPS}`; do
    # get some basics in place, no prep in prod deploy
    GROUP=${g%%:*}
    PROJECT=${g##*:}

    CONF="/home/`whoami`/.kube/cfg-${GROUP}"
    if [ ! -e ${CONF} ] ; then
        # this is a dev machine
        prep ${PROJECT}
        CONF=""
    fi

    TSTAMPDIR=${GROUP}-${TSTAMP}
    mkdir -p ${TSTAMPDIR}

    pull_tag ${GROUP} $TSTAMPDIR

    for f in `ls $TSTAMPDIR/*`; do
        oc_apply $f
    done

    if [ $(find ${TSTAMPDIR}/ -name \*.yaml | wc -l ) -lt 1 ]; then
        # if we didnt apply anything, dont keep the dir around
        rm -rf $TSTAMPDIR
        echo "R: Nothing to apply"
    fi
done


