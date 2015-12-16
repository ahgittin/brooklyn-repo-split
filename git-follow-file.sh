git log --format='%H' --name-status --follow -- $1 | awk '{if ($3) print $3; if ($2) print $2;}' | uniq
