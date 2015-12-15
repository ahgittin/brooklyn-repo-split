
. env.sh

for x in $PROJS ; do
  ./make-whitelist.sh incubator-brooklyn/ "brooklyn-$x $(cat common-whitelist.txt) $(cat $x-whitelist.txt)" $x-whitelist.full.txt
done

./make-whitelist.sh incubator-brooklyn/ "brooklyn $(cat common-whitelist.txt) README.md" brooklyn-uber-repo-whitelist.full.txt

# finally anything which isn't in any full whitelist, put into unclaimed-whitelist.txt

pushd incubator-brooklyn

git rev-list --objects --all | awk '{print $2}' | sort | uniq > ../all-files-ever.txt

popd

cat *-whitelist.full.txt | sort | uniq > all-files-claimed.txt

# keep only lines in all-files-ever which aren't in all-files-claimed
grep -v -x -f all-files-claimed.txt all-files-ever.txt > unclaimed-whitelist.txt

# put unclaimed files in the server whitelist so we don't lose them
cat unclaimed-whitelist.txt >> server-whitelist.full.txt

