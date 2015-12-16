
# efficient way to find lines beginning with any of the given prefixes, sorted
# much faster than grep -f (with or without -F) for big files because of the line start logic and sort -- O(N log N) rather than O(N^2)

if [ -z "$2" ] ; then echo "Usage:  grep-lines-starting.sh <prefix_file> <lines>     # to find all lines starting with any prefix in <prefix_file>" ; exit 1 ; fi

PREFIX_FILE=$1
INPUT=$2
TMP=/tmp/remove-prefixes-tmp

cat $PREFIX_FILE | awk '{if ($1) print $0"\tMATCH_THIS" }' | cat - $INPUT | sort -u > ${TMP}_merged
cat ${TMP}_merged | awk -F $'\t' '{
    if ($2=="MATCH_THIS") {
      if (!patt || substr($1,0,length(patt))!=patt) { patt=$1; }
      if (last==patt) { print last; }
    } else {
      last=$0;
      if (patt && substr(last,0,length(patt))==patt) { print last; }
    } }' | sort -u

