
. env.sh

set -e
set -x

pushd incubator-brooklyn

git reset --hard
git clean -df

for x in $PROJS ; do mkdir -p brooklyn-$x ; done
mkdir -p brooklyn

for x in `ls | grep brooklyn` ; do cp .gitattributes .gitignore LICENSE NOTICE README.md $x ; done

mv usage/all usage/dist usage/scripts usage/downstream-parent usage/archetypes release brooklyn-dist

mv usage/cli brooklyn-server/server-cli
mv parent api core policy utils camp locations usage/rest-* usage/logback-* usage/launcher usage/qa usage/test-* storage karaf  brooklyn-server
mv usage/camp brooklyn-server/camp/camp-brooklyn

mv usage/jsgui/* brooklyn-ui
cat usage/jsgui/.gitignore >> brooklyn-ui/.gitignore
rm -rf usage

mv software examples sandbox brooklyn-library

mv docs/{*,.gitignore} brooklyn-docs
rm -rf docs

popd

