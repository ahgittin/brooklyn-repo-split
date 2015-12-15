#!/usr/bin/env bash

set -x
set -e


# reorganise to match new repos

basedir=$(pwd)
branches="0.4 0.4.0 0.4.0-M1 0.4.0-M2 0.4.0-rc.1 0.4.0-rc.2 0.5 0.5.0 0.5.0-M1 0.5.0-M2 0.5.0-rc.1 0.5.0-rc.2 0.6.0 0.6.0-M1 0.6.0-M2 0.6.0-rc.1 0.6.0-rc.2 0.6.0-rc.3 0.6.0-rc.4 0.6.x 0.7.0-M1 0.7.0-M1-amp-2.0.0-M1 0.7.0-M2-incubating 0.7.0-M2-incubating-docs 0.7.0-incubating 0.8.0-incubating"

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
        git filter-branch --tag-name-filter cat --commit-filter ${basedir}'/remove-pointless-commit.rb "$@"' master ${branches} &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git reflog expire --expire=now --all &&
        git gc --prune=now )
}

. env.sh


# clean up the history, globally

mkdir new-repos
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
( cd new-repos/TEMP-brooklyn-server && git filter-branch --index-filter "git rm -q -r --cached --ignore-unmatch $( cat ../../{docs,library,ui,dist}-whitelist.txt | tr '\n' ' ' )" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn-server
