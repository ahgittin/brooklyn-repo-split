#!/usr/bin/env bash

set -x
set -e

. env.sh

# ensure branches are all checked out, updated, and restored
( cd incubator-brooklyn && git fetch )
( cd incubator-brooklyn && for branch in ${branches}; do [ -z "$( git branch --list ${branch} )" ] && git branch --track ${branch} origin/${branch} || true; done )
( cd incubator-brooklyn && git checkout master && git reset --hard origin/master )
# use the "reorg" branch for cleaned history, but first update everything from origin
( cd incubator-brooklyn && git pull && ( git branch -D reorg || true) && 
  ( for x in $(git branch | cut -c 3-) ; do git checkout $x ; git reset --hard origin/$x ; done ) &&
  git checkout master && git checkout -b reorg )


# REARRANGE has been done, so this should now be skipped
# ./1-rearrange-incubator.sh

# this is applied to all branches, local repo only; 
# should NOT be pushed, it's just the basis for the splitting
./2-clean-history.sh

# now create the list of files relevant to each subproject
./3-create-full-whitelists.sh

# make the new repos, in new-repos/
./4-make-new-repos.sh

