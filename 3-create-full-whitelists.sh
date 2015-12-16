#!/usr/bin/env bash

set -x
set -e

. env.sh

for x in $PROJS uber-repo ; do
  echo brooklyn-$x | cat - $x-whitelist.txt common-whitelist.txt > TMP-whitelist-$x.gen.txt
  ./make-whitelist.sh incubator-brooklyn/ TMP-whitelist-$x.gen.txt $x-whitelist.full.gen.txt
  rm TMP-whitelist-$x.gen.txt
done

# finally anything which isn't in any full whitelist, put into unclaimed-whitelist.gen.txt

pushd incubator-brooklyn

git log --pretty=format: --name-only --diff-filter=A | sort -u > ../all-files-ever.gen.txt 

popd

cp server-whitelist.full.gen.txt server-only-whitelist.full.gen.txt
cat *-whitelist.full.gen.txt | sort -u > all-files-claimed.gen.txt

# keep only lines in all-files-ever which aren't in all-files-claimed
# (comm is a cool command; didn't even know about it; requies things sorted, which they are, and it's fast)
comm -13 all-files-claimed.gen.txt all-files-ever.gen.txt > unclaimed-files.gen.txt

# put unclaimed files in the server whitelist so we don't lose them
# keep the server-only files in case useful
cat server-only-whitelist.full.gen.txt unclaimed-files.gen.txt | sort -u > server-whitelist.full.gen.txt

