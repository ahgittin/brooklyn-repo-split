#!/usr/bin/env bash

set -x
set -e

# quick remove of uncontroversial things
#git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch com.cloudsoftcorp.monterey.brooklyn gemfire monterey-example' HEAD

# other example projects - some versions contain binaries, other versions have had the binaries removed

# option 1: just delete the binaries - means that the historical version won't compile/run
#git filter-branch --index-filter 'git -r --cached --ignore-unmatch examples/simple-messaging-pubsub/resources/lib/guava-11.0.2.jar
#    examples/simple-messaging-pubsub/resources/lib/log4j-1.2.14.jar
#    examples/simple-messaging-pubsub/resources/lib/qpid-client-0.14.jar
#    examples/simple-messaging-pubsub/resources/lib/qpid-common-0.14.jar
#    examples/simple-messaging-pubsub/src/main/resources/je-5.0.34.jar
#    examples/simple-nosql-cluster/src/main/resources/cumulusrdf-0.6.1-pre.jar
#    examples/simple-nosql-cluster/src/main/resources/cumulusrdf.war
#    examples/simple-nosql-cluster/src/main/resources/cumulusrdf.war
#    sandbox/examples/src/main/resources/gemfire/springtravel-datamodel.jar
#    sandbox/examples/src/main/resources/swf-booking-mvc.war' HEAD

# option 2: delete the entire example *if* it contains binaries but keep it if it doesn't - means that the project will suddenly appear in history but should work when it does appear
#git filter-branch --tree-filter 'for p in examples/simple-messaging-pubsub examples/simple-nosql-cluster sandbox/examples; do
#    find . -name '*.?ar' | egrep '.*' && rm -rf $p; done'

# reorganise to match new repos

function new_repo() {
    repodir=new-repos/TEMP-$1
    git clone incubator-brooklyn $repodir
    ( cd $repodir &&
        for branch in ${branches}; do git branch --track ${branch} origin/${branch}; done &&
        git remote remove origin &&
        git remote add origin https://github.com/rdowner/TEMP-$1.git )
}
function cleanup() {
    ( cd new-repos/TEMP-$1 &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git filter-branch --tag-name-filter cat --commit-filter $(basedir)'/remove-pointless-commit.rb "$@"' master ${branches} &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git reflog expire --expire=now --all &&
        git gc --prune=now )
}

basedir=$(pwd)
branches="0.4 0.4.0 0.4.0-M1 0.4.0-M2 0.4.0-rc.1 0.4.0-rc.2 0.5 0.5.0 0.5.0-M1 0.5.0-M2 0.5.0-rc.1 0.5.0-rc.2 0.6.0 0.6.0-M1 0.6.0-M2 0.6.0-rc.1 0.6.0-rc.2 0.6.0-rc.3 0.6.0-rc.4 0.6.x 0.7.0-M1 0.7.0-M1-amp-2.0.0-M1 0.7.0-M2-incubating 0.7.0-M2-incubating-docs 0.7.0-incubating 0.8.0-incubating"

mkdir new-repos
( cd incubator-brooklyn && for branch in ${branches}; do [ -z "$( git branch --list ${branch} )" ] && git branch --track ${branch} origin/${branch} || true; done )
( cd incubator-brooklyn && git checkout master )

new_repo brooklyn-docs
( cd new-repos/TEMP-brooklyn-docs && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/docs-whitelist.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-docs

new_repo brooklyn-library
( cd new-repos/TEMP-brooklyn-library && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/library-whitelist.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-library

new_repo brooklyn-ui
( cd new-repos/TEMP-brooklyn-ui && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/ui-whitelist.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-ui

new_repo brooklyn-dist
( cd new-repos/TEMP-brooklyn-dist && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/dist-whitelist.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-dist

new_repo brooklyn-server
( cd new-repos/TEMP-brooklyn-server && git filter-branch --index-filter "git rm -q -r --cached --ignore-unmatch $( cat ../../*-whitelist.txt | tr '\n' ' ' ); done" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-server
