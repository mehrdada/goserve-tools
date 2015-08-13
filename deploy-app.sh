#!/bin/sh

SRC=/srv/git
WEB=/srv/web
TST=/srv/staging
CONF=/srv/config.js
VER=`mktemp`;

cd $SRC
git fetch origin +live:live +test:test

echo "module.exports = '`git --git-dir=$SRC log live -1 | head -1 | cut -d \  -f 2`';" > $VER
if cmp -s $VER $WEB/version.js; then
	echo live branch unchanged, not updating.
else
	rm -fr $WEB;
	mkdir -p -m0755 $WEB;
	GIT_INDEX_FILE=`mktemp -u` GIT_DIR=$SRC GIT_WORK_TREE=$WEB git checkout -f live > /dev/null 2>&1
	cp -f $VER $WEB/version.js;
	cp -f $CONF $WEB;
	git --git-dir=$SRC log live -1 | head -1 | cut -d \  -f 2 > $WEB/revision
	chmod 400 $WEB/config.js;
	sudo restart app;
fi

echo "module.exports = 'STAGING: `git --git-dir=$SRC log test -1 | head -1 | cut -d \  -f 2`';" > $VER;
if cmp -s $VER $TST/version.js; then
	echo test branch unchanged, not updating.
else
	rm -fr $TST;
	mkdir -p -m0755 $TST;
	GIT_INDEX_FILE=`mktemp -u` GIT_DIR=$SRC GIT_WORK_TREE=$TST git checkout -f test > /dev/null 2>&1
	cp -f $VER $TST/version.js;
	git --git-dir=$SRC log test -1 | head -1 | cut -d \  -f 2  > $TST/revision
	sudo restart app.staging;
fi

