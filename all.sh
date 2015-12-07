#!/usr/bin/env bash

set -x
set -e

. env.sh

# ensure branches are all checked out
( cd incubator-brooklyn && for branch in ${branches}; do [ -z "$( git branch --list ${branch} )" ] && git branch --track ${branch} origin/${branch} || true; done )
( cd incubator-brooklyn && git checkout master )

# now restructure *in the old repo*

./rearrange-incubator.sh

# TODO commit above

# TODO prune incubator history
# big files
# quick remove of uncontroversial things
#git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch com.cloudsoftcorp.monterey.brooklyn gemfire monterey-example' HEAD


# TODO update whitelists
# TODO script doesn't yet take arguments
# ./make-whitelist.sh incubator-brooklyn/ "brooklyn-server api core" server-whitelist.txt
# TODO others


# make new repos

# TODO this currently has the contents of the old split.sh, unchanged
# ./make-new-repos.sh
