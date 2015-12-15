
. env.sh

for x in $PROJS ; do
  ./make-whitelist.sh incubator-brooklyn/ "brooklyn-$x $(cat common-whitelist.txt) $(cat $x-whitelist.txt)" $x-whitelist.full.txt
done

./make-whitelist.sh incubator-brooklyn/ "brooklyn $(cat common-whitelist.txt) README.md" brooklyn-uber-repo-whitelist.full.txt

# finally anything which isn't in any full whitelist, put into unclaimed-whitelist.txt

pushd incubator-brooklyn

git log --pretty=format: --name-only --diff-filter=A | sort -u > ../all-files-ever.txt 

popd

cat *-whitelist.full.txt | sort -u > all-files-claimed.txt

# keep only lines in all-files-ever which aren't in all-files-claimed
# (comm is a cool command; didn't even know about it; requies things sorted, which they are, and it's fast)
comm -13 all-files-claimed.txt all-files-ever.txt > unclaimed-files.txt

# put unclaimed files in the server whitelist so we don't lose them
# keep the server-only files in case useful
cp server-whitelist.full.txt server-only-whitelist.full.txt
cat server-only-whitelist.full.txt unclaimed-files.txt | sort -u > server-whitelist.full.txt

