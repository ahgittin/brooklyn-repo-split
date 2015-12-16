#!/usr/bin/env bash

set -x
set -e


# reorganise to match new repos

. env.sh

function new_repo() {
    repodir=new-repos/${REPO_PREFIX}$1
    git clone incubator-brooklyn $repodir
    # for quick tests:
#    git clone --depth 10 file://`pwd`/incubator-brooklyn $repodir && ( cd $repodir && git fetch --depth 10 )
    ( cd $repodir &&
        for branch in ${branches}; do git branch --track ${branch} origin/${branch}; done &&
        git remote rm origin &&
        git remote add origin https://github.com/${REPO_ORG}/${REPO_PREFIX}$1.git )
}
function filter_repo() {
  # testing which is fastest
#  filter_repo_removing_explicit $1 $2
  filter_repo_update_index_explicit $1 $2
}
function filter_repo_update_index_explicit() {
  # update-index is much faster than git-rm and simpler without the pre-processing
  ( cd new-repos/${REPO_PREFIX}$1 && \
    git filter-branch --index-filter \
      "git ls-files | comm -23 - ${basedir}/$2 | git update-index --force-remove --stdin" \
      --tag-name-filter cat --prune-empty master ${branches} )
}
function filter_repo_rm_all_then_add() {
  # :( this doesn't work, as we don't have content to add, and reset doesnt work also
  ( cd new-repos/${REPO_PREFIX}$1 && \
    git filter-branch --index-filter "git ls-files > /tmp/TMP-files-to-add ; git rm -q -r --cached --ignore-unmatch * ; comm -12 /tmp/TMP-files-to-add ${basedir}/$2 | tr '\n' '\0' | xargs -0 -n 1000 git reset" \
      --tag-name-filter cat --prune-empty master ${branches} )
}
function filter_repo_removing_explicit() {
  # use -0 and tr so files with spaces are passed as single words
  # batch by 1000 to avoid xargs insufficient space error
  # don't need to do -r on rm since it's explicit files (but that doesn't speed it up much)
  ( cd new-repos/${REPO_PREFIX}$1 && \
    git filter-branch --index-filter "git ls-files | comm -23 - ${basedir}/$2 | tr '\n' '\0' | xargs -0 -n 1000 git rm -q --cached --ignore-unmatch" \
      --tag-name-filter cat --prune-empty master ${branches} )
}

function filter_repo_update_ruby_whitelist() {
  # this is the original technique, using ruby -- allows path prefixes
  # but we now use explicit file lists for which it becomes inefficient
  # (also note: the common-whitelist is in the gen list, and it will break if xargs is too long (but those are easily fixed))
  ( cd new-repos/${REPO_PREFIX}$1 && \
    git filter-branch --index-filter \
      "git ls-files | ${basedir}/filter_whitelist.rb ${basedir}/common-whitelist.txt ${basedir}/$2 | xargs -0 git rm -q -r --cached --ignore-unmatch" \
      --tag-name-filter cat --prune-empty master ${branches} )
}


function cleanup_repo() {
    ( cd new-repos/${REPO_PREFIX}$1 &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git filter-branch --tag-name-filter cat --commit-filter ${basedir}'/remove-pointless-commit.rb "$@"' master ${branches} &&
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d &&
        git reflog expire --expire=now --all &&
        git gc --prune=now )
}
function commit_repo() {
  pushd new-repos/${REPO_PREFIX}$1
  git rm --ignore-unmatch .gitattributes .gitignore README.md NOTICE LICENSE 
  git mv $1/{*,.??*} ./
  git add -A
  git commit -m 'move subdir from incubator up a level as it is promoted to its own repo (first non-incubator commit!)'
  popd
}

function do_repo_w_whitelist() {
  new_repo $1
  filter_repo $1 $2
  cleanup_repo $1
  commit_repo $1
}

# clean up the history, globally

rm -rf new-repos

mkdir new-repos

for x in $PROJS ; do
  do_repo_w_whitelist brooklyn-$x $x-whitelist.full.gen.txt
done

do_repo_w_whitelist brooklyn uber-repo-whitelist.full.gen.txt

