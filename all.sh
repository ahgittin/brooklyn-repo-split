#!/usr/bin/env bash

set -x
set -e

. env.sh

# ensure branches are all checked out
( cd incubator-brooklyn && git fetch )
( cd incubator-brooklyn && for branch in ${branches}; do [ -z "$( git branch --list ${branch} )" ] && git branch --track ${branch} origin/${branch} || true; done )
( cd incubator-brooklyn && git checkout master && git reset --hard origin/master )

# now restructure *in the old repo*

./1-rearrange-incubator.sh
# committed to 'reorg' branch which could be pushed

./2-clean-history.sh
# should affect all branches, but should NOT be pushed
# it's just the basis for the splitting

./3-create-full-whitelists.sh


# make the new repos, in new-repos/
./4-make-new-repos.sh
