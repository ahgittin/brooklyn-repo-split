
. env.sh

set -e
set -x

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

mv usage/all usage/dist usage/scripts usage/downstream-parent usage/archetypes release brooklyn-dist/

mv usage/cli brooklyn-server/server-cli
mkdir brooklyn-server/software
mv software/base software/winrm brooklyn-server/software/
mkdir brooklyn-server/logging
mv usage/logback-* brooklyn-server/logging/
mkdir brooklyn-server/rest
mv usage/rest-* brooklyn-server/rest/
mv parent api core policy utils camp locations usage/launcher usage/test-* storage karaf  brooklyn-server/
mv usage/camp brooklyn-server/camp/camp-brooklyn

mv usage/qa software examples sandbox brooklyn-library/

mv usage/jsgui/* brooklyn-ui
cat usage/jsgui/.gitignore >> brooklyn-ui/.gitignore
rm -r usage

mv docs/{*,.gitignore} brooklyn-docs/
rm -r docs

popd

