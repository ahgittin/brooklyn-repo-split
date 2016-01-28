
# inputs

if [ -z "$3" ]; then echo "Usage: make-whitelist.sh REPO_DIR PATH_PREFIX_FILE OUTPUT_FILENAME" ; exit 1 ; fi

export REPO=$1
export PREFIX_FILE=$2
export OUTPUT_FILENAME=$3

# output

export ORIG_DIR=`pwd`
export OUTPUT=${ORIG_DIR}/${OUTPUT_FILENAME}


# working

# file/paths we have left to look at, built up for the next cycle on one cycle,
# starting with the PREFIX_FILE
export TODO_REMAINING=${ORIG_DIR}/TODO-remaining

# file/paths encountered on one cycle
export TODO_HERE=${ORIG_DIR}/TODO-here

sort -u -o $OUTPUT $PREFIX_FILE
cp $OUTPUT $TODO_REMAINING
SAMPLE_PATHS=`head -4 $PREFIX_FILE`" and "`( gshuf $PREFIX_FILE 2> /dev/null || echo "maybe others" ) | head -4`

pushd $REPO > /dev/null

echo scanning $REPO for relevant files in history for $OUTPUT_FILENAME starting with `cat $TODO_REMAINING | wc -l` paths including $SAMPLE_PATHS

# first seed with existing files, dropping an extra / which find might put in, in case any existing files aren't picked up by the log (e.g. on merge)
cat ${TODO_REMAINING} | xargs -J % -n1 find % -type file 2> /dev/null | sed s/\\/\\//\\// >> ${OUTPUT}

while [ -s $TODO_REMAINING ] ; do

  echo current pass has `cat $TODO_REMAINING | wc -l` paths including `( gshuf $TODO_REMAINING 2> /dev/null || cat $TODO_REMAINING ) | head -4`

#  echo PICKED UP for $OUTPUT_FILENAME : >> ${ORIG_DIR}/log
#  cat $TODO_REMAINING >> ${ORIG_DIR}/log

  rm -f $TODO_HERE

  echo collecting relevant commits...
  cat $TODO_REMAINING | xargs -n100 git log --format='%H' --diff-filter=A -- >> ${TODO_HERE}_ids

  sort -u ${TODO_HERE}_ids -o ${TODO_HERE}_ids
#  echo IDS | cat - ${TODO_HERE}_ids >> ${ORIG_DIR}/log

  rm -f ${TODO_HERE}_allpaths
  echo gathering files from `cat ${TODO_HERE}_ids | wc -l` commits...
  # 50% match is a bit low but better safe than sorry for moves; for copies we go higher
  cat ${TODO_HERE}_ids | xargs -n100 git show -l99999 -M50 -C90 --name-status --format="ID: %H" | grep -v ^ID: | awk -F $'\t' '{ if ($3) print $3"\t"$2; else print $2; }' | sort -u >> ${TODO_HERE}_allpaths

  echo comparing `cat ${TODO_HERE}_allpaths | wc -l` candidate files against paths...
  ${ORIG_DIR}/grep-lines-starting.sh ${TODO_REMAINING} ${TODO_HERE}_allpaths | awk -F $'\t' '{print $1; if ($2) print $2;}' | sort -u -o ${TODO_HERE}

  comm -23 ${TODO_HERE} $OUTPUT > ${TODO_REMAINING}
  cat $OUTPUT ${TODO_HERE} | sort -u -o ${OUTPUT}
  rm ${TODO_HERE}_*

done

popd > /dev/null

rm ${TODO_REMAINING}
rm ${TODO_HERE}

echo completed scan of $REPO in $OUTPUT_FILENAME, relevant history has `wc ${OUTPUT} | awk '{print $1}'` files

