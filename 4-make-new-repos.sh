#!/usr/bin/env bash

set -x
set -e


# reorganise to match new repos

. env.sh

function new_repo() {
    repodir=new-repos/${REPO_PREFIX}$1
    git clone incubator-brooklyn $repodir
    ( cd $repodir &&
        for branch in ${branches}; do git branch --track ${branch} origin/${branch}; done &&
        git remote rm origin &&
        git remote add origin https://github.com/${REPO_ORG}/${REPO_PREFIX}$1.git )
}
function cleanup() {
    ( cd new-repos/${REPO_PREFIX}$1 &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git filter-branch --tag-name-filter cat --commit-filter ${basedir}'/remove-pointless-commit.rb "$@"' master ${branches} &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git reflog expire --expire=now --all &&
        git gc --prune=now )
}


# clean up the history, globally

rm -rf new-repos

mkdir new-repos

for x in $PROJS ; do
  new_repo brooklyn-$x
  ( cd new-repos/${REPO_PREFIX}brooklyn-$x && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/$x-whitelist.full.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
  cleanup brooklyn-$x
  git rm .gitattributes .gitignore README.md NOTICE LICENSE
  git mv brooklyn-$x/{*,.??*} ./
done

new_repo brooklyn
( cd new-repos/${REPO_PREFIX}brooklyn && git filter-branch --index-filter "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/brooklyn-uber-repo-whitelist.full.txt | xargs -0 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn

