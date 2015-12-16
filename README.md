# brooklyn-repo-split

This is the scripts needed to split the Apache Brooklyn repository into smaller modules, as agreed by vote on the community's dev
mailing list.

To try it out:

```{shell}
git clone https://github.com/rdowner/brooklyn-repo-split.git
cd brooklyn-repo-split
git submodule init
git submodule update
./all.sh
```

Then look for the results:
* in `incubator-brooklyn`, a `reorg` branch which restructures incubator along lines of the new projects
* in `new-repos`, all the new repos we want to create appropriately carved up including carved up history

Running this script can take a couple of hours.  You can run parts of it; see below.


## Files

The script runs several stages, as indicated by the commands `1-*.txt`, `2-*.txt`, ... .
For the most part these can be run individually.

There are a few other scripts `*.sh` and programs `*.rb` used by the scripts above.

The files `*-whitelist.txt` files list the initial whitelists to use for each project.
If any projects are restructured these should be kept consistent with script `1-rearrange-incubator.sh`.

Files `*.gen.txt` are auto-generated.
In particular the files `*-whitelist.full.gen.txt` contain the final expanded whitelists,
auto-generated by step 3.
These are checked in as it is useful to cache these and to observe changes
(but these may need updating after any change to the incubator project).

The files `big-to-small.*` are a script and output of a program which records the biggest files in the history.


## Steps

Steps 1 and 2 are done and checked in as `reorg*` branches at https://github.com/ahgittin/incubator-brooklyn .

Step 3 has been run and the results checked in here (`*-whitelist.full.gen.txt`).

*All steps will need re-run as more changes are pushed to incubator (or any corresponding changes applied to those branches).*

The steps are now pretty quick, with 1 taking <1m, 2 taking 20m, 3 taking 3m, on my box.
Step 4 takes the longest, about 15m per sub-repo or 1h30m total.


## References

http://naleid.com/blog/2012/01/17/finding-and-purging-big-files-from-git-history

