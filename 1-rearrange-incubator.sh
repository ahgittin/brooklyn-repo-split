#!/usr/bin/env bash

set -x
set -e

. env.sh

pushd incubator-brooklyn

git reset --hard
git checkout master
git pull
git branch -D reorg || true
git checkout -b reorg
git clean -df


for x in $PROJS ; do mkdir -p brooklyn-$x ; done
mkdir -p brooklyn

for x in `ls | grep brooklyn` ; do cp .gitattributes .gitignore LICENSE NOTICE README.md $x ; done

git mv usage/all usage/dist usage/scripts usage/downstream-parent usage/archetypes release brooklyn-dist/

git mv usage/cli brooklyn-server/server-cli
mkdir brooklyn-server/software
git mv software/base software/winrm brooklyn-server/software/
mkdir brooklyn-server/logging
git mv usage/logback-* brooklyn-server/logging/
mkdir brooklyn-server/rest
git mv usage/rest-* brooklyn-server/rest/
git mv parent api core policy utils camp locations usage/launcher usage/test-* storage karaf  brooklyn-server/
git mv usage/camp brooklyn-server/camp/camp-brooklyn

git mv usage/qa software examples sandbox brooklyn-library/

git mv usage/jsgui/* brooklyn-ui
cat usage/jsgui/.gitignore >> brooklyn-ui/.gitignore
rm usage/jsgui/.gitignore

rm brooklyn-docs/README.md
git mv docs/* brooklyn-docs/
cat docs/.gitignore >> brooklyn-docs/.gitignore
rm docs/.gitignore

git add -A
git commit -m 'rearranged to have structure of new repositories'

git clean -df
# this should get rid of usage and docs unless they somehow became non-empty

echo reorg done in reorg branch in `pwd`

popd

