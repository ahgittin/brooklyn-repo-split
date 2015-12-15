
. env.sh

## notes: this command will list big files
# git rev-list --objects --all | sort -k 2 > allfileshas.txt

pushd incubator-brooklyn
git checkout master
git branch -D reorg-history-cleaned
git checkout -b reorg-history-cleaned

git filter-branch --index-filter "git rm -r --cached --ignore-unmatch $(echo $( cat ${basedir}/big-files-to-remove.txt ))" HEAD

# option 2: delete the entire example *if* it contains binaries but keep it if it doesn't - means that the project will suddenly appear in history but should work when it does appear
# (we have gone for option 1, just cutting the big files)
#git filter-branch --tree-filter 'for p in examples/simple-messaging-pubsub examples/simple-nosql-cluster sandbox/examples; do
#    find . -name '*.?ar' | egrep '.*' && rm -rf $p; done'



# A few extra steps are needed to properly clean the history - see this extract from the git filter-branch help page

# Remove the original refs backed up by git-filter-branch: say 
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

# Expire all reflogs with 
git reflog expire --expire=now --all

# Garbage collect all unreferenced objects with 
git gc --prune=now
# (or if your git-gc is not new enough to support arguments to --prune, use git repack -ad; git prune instead).


popd

