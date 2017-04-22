#!/bin/bash

# this script relies on github.com/openshiftio/saas set as remote: upstream
# and a local checkout with origin mapped to a github repo

which hub 2>&1 > /dev/null
if [ $? -ne 0 ]; then
	echo 'need hub from hub.github.com installed'
fi

mkdir -p last_pr_sent
TSTAMP=$(date +%Y%m%d_%H%M%S)
git checkout master
git pull --rebase upstream master
git checkout -b $TSTAMP
python jenkins-update.py

# XXX we are not building f8-forker with a hash yet
# so lets ignore that for now
git checkout dsaas-services/f8-forker.yaml

# check we havent already PR'd this
for f in `find dsaas-services/ -name \*.yaml` ; do
	if [ -e last_pr_sent/`basename $f` ]; then
		difflines=$(diff $f last_pr_sent/`basename $f` | wc -l)
		if [ $difflines -lt 1 ]; then
			git checkout $f
		fi
	fi

done

a=$(git status | grep dsaas-services| wc -l)
if [ $a -gt 0 ]; then
	cp -f dsaas-services/* last_pr_sent/
	git add dsaas-services/*
	git commit -m "Update to ${TSTAMP}" dsaas-services/*
	git push origin $TSTAMP
	hub pull-request -m "Update to ${TSTAMP}"
else
	git checkout master
	git branch -D $TSTAMP
fi

#git checkout master
#git branch -D $TSTAMP