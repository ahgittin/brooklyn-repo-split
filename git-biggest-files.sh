
# lists files in history in size order, to stdout
# capped at 200 of the biggest blobs by default; or provide the max as the parameter, e.g. git-biggest-files.sh 10

SIZE=200

if [ ! -z "$1" ] ; then SIZE=$1 ; fi

# however this does not show the former names of the blobs so if the same file is in 
# multiple times this script will show only one instance; apply `git-follow-file` to do that
# e.g.   git-biggest-files.sh | while read line ; do if [ ! -z "$( echo $line | awk '{print $3}' )" ] ; then echo $( echo $line | awk '{print $2 }' ) $( git-follow-file.sh $( echo $line | awk '{print $3}' )) ; fi ; done

git rev-list --objects --all | sort -k 2 > /tmp/TMP-big-shas.txt
git gc 2> /tmp/TMP-big-log.txt && git verify-pack -v .git/objects/pack/pack-*.idx | egrep "^\w+ blob\W+[0-9]+ [0-9]+ [0-9]+$" | sort -k 3 -n -r | head -${SIZE} > /tmp/TMP-big-objects.txt
for SHA in `cut -f 1 -d\  < /tmp/TMP-big-objects.txt`; do echo $(grep $SHA /tmp/TMP-big-objects.txt) $(grep $SHA /tmp/TMP-big-shas.txt) | awk '{print $1,$3,$7}' ; done;

rm /tmp/TMP-big-* 

