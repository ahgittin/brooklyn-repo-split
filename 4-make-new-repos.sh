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
  # use -0 and tr so files with spaces are passed as single words
  # batch by 1000 to avoid xargs insufficient space error
  ( cd new-repos/${REPO_PREFIX}brooklyn-$x && git filter-branch --index-filter "git ls-files | comm -23 - ${basedir}/$x-whitelist.full.gen.txt | tr '\n' '\0' | xargs -0 -n 1000 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
  cleanup brooklyn-$x
  git rm .gitattributes .gitignore README.md NOTICE LICENSE
  git mv brooklyn-$x/{*,.??*} ./
done

new_repo brooklyn
( cd new-repos/${REPO_PREFIX}brooklyn && git filter-branch --index-filter "git ls-files | comm -23 - ${basedir}/brooklyn-uber-repo-whitelist.gen.txt | tr '\n' '\0' | xargs -0 -n 1000 git rm -q -r --cached --ignore-unmatch" --tag-name-filter cat --prune-empty master ${branches} )
cleanup brooklyn

