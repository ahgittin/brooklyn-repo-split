
PROJS_NO_SERVER="dist ui library docs"
PROJS="$PROJS_NO_SERVER server"

basedir=$(pwd)

# branches="0.4 0.4.0 0.4.0-M1 0.4.0-M2 0.4.0-rc.1 0.4.0-rc.2 0.5 0.5.0 0.5.0-M1 0.5.0-M2 0.5.0-rc.1 0.5.0-rc.2 0.6.0 0.6.0-M1 0.6.0-M2 0.6.0-rc.1 0.6.0-rc.2 0.6.0-rc.3 0.6.0-rc.4 0.6.x 0.7.0-M1 0.7.0-M1-amp-2.0.0-M1 0.7.0-M2-incubating 0.7.0-M2-incubating-docs 0.7.0-incubating 0.8.0-incubating"
# only keep these (most interesting) branches
branches="0.4.0 0.5.0 0.6.0 0.7.0-incubating 0.8.0-incubating"

# change this to an empty string when finished
REPO_PREFIX=TEMP-
REPO_ORG=rdowner

