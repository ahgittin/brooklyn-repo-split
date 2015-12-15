
# inputs

# TODO take inputs, including OUTPUT_FILENAME

if [ -z "$3" ]; then echo "Usage: make-whitelist.sh REPO_DIR DIRS_TO_FOLLOW OUTPUT_FILENAME" ; exit 1 ; fi

export REPO=$1
export DIRS=$2
export OUTPUT_FILENAME=$3

# output

export ORIG_DIR=`pwd`
export OUTPUT=${ORIG_DIR}/${OUTPUT_FILENAME}


# working

# file/paths we have left to look at, built up for the next cycle on one cycle,
# starting with the DIRS
export TODO_REMAINING=${ORIG_DIR}/TODO-remaining

# file/paths encountered on one cycle
export TODO_HERE=${ORIG_DIR}/TODO-here


rm $OUTPUT
for x in $DIRS ; do echo $x >> $OUTPUT ; done
cp $OUTPUT $TODO_REMAINING

pushd $REPO > /dev/null

echo scanning $REPO for all files

while [ -s $TODO_REMAINING ] ; do

  echo current scan has `wc $TODO_REMAINING | awk '{print $1}'` paths including `head -1 $TODO_REMAINING`
  rm -f $TODO_HERE
  touch $TODO_HERE

  for x in `cat $TODO_REMAINING` ; do
    # NB: this doesn't work with spsces in the filename; we just have a few though and they're manually added
    git log --format='%H' --name-status --follow -- $x | awk '{if ($3) print $3; if ($2) print $2;}' | sort -u | cat $TODO_HERE - > ${TODO_HERE}2
    mv ${TODO_HERE}2 ${TODO_HERE}
  done
  cat ${TODO_HERE} | sort -u > ${TODO_HERE}2
  mv ${TODO_HERE}2 ${TODO_HERE}

  diff --new-line-format="" --unchanged-line-format="" ${TODO_HERE} $OUTPUT > ${TODO_HERE}_new
  cat $OUTPUT ${TODO_HERE}_new | sort -u > ${OUTPUT}2
  mv ${OUTPUT}2 ${OUTPUT}
  mv ${TODO_HERE}_new $TODO_REMAINING

done

popd > /dev/null

rm ${TODO_REMAINING}
rm ${TODO_HERE}

echo completed scan of $REPO, history has `wc ${OUTPUT} | awk '{print $1}'` files

