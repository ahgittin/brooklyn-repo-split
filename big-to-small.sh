
# lists files in history in size order, in big-to-small.txt
# capped at 200 of the biggest blobs (generating about 3000 of the biggest size files in history)

pushd incubator-brooklyn
git rev-list --objects --all | sort -k 2 > ../TMP-allfileshas.txt
git gc && git verify-pack -v .git/objects/pack/pack-*.idx | egrep "^\w+ blob\W+[0-9]+ [0-9]+ [0-9]+$" | sort -k 3 -n -r | head -200 > ../TMP-bigobjects.txt
for SHA in `cut -f 1 -d\  < ../TMP-bigobjects.txt`; do echo $(grep $SHA ../TMP-bigobjects.txt) $(grep $SHA ../TMP-allfileshas.txt) | awk '{print $1,$3,$7}' >> ../big-to-small.txt; done;
popd

rm TMP-*

