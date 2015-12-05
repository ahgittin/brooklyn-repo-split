# brooklyn-repo-split

This is the scripts needed to split the Apache Brooklyn repository into smaller modules, as agreed by vote on the community's dev
mailing list.

To try it out:

```{shell}
git clone https://github.com/rdowner/brooklyn-repo-split.git
cd brooklyn-repo-split
git submodule init
git submodule update
./split.sh
```

then look for the results in the `new-repos` folder.

Running this script takes slightly more than an hour on an AWS r3.xlarge instance running everything inside a ramfs RAM disk.
