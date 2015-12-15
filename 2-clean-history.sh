
. env.sh

echo size before cleaning history:
du -h -d 0 || echo du depth arg not supported here

pushd incubator-brooklyn
git branch -D reorg-history-cleaned
git checkout -b reorg-history-cleaned

git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch com.cloudsoftcorp.monterey.brooklyn gemfire monterey-example' HEAD
git filter-branch --index-filter 'git -r --cached --ignore-unmatch examples/simple-messaging-pubsub/resources/lib/guava-11.0.2.jar
    examples/simple-messaging-pubsub/resources/lib/log4j-1.2.14.jar
    examples/simple-messaging-pubsub/resources/lib/qpid-client-0.14.jar
    examples/simple-messaging-pubsub/resources/lib/qpid-common-0.14.jar
    examples/simple-messaging-pubsub/src/main/resources/je-5.0.34.jar
    examples/simple-nosql-cluster/src/main/resources/cumulusrdf-0.6.1-pre.jar
    examples/simple-nosql-cluster/src/main/resources/cumulusrdf.war
    examples/simple-nosql-cluster/src/main/resources/cumulusrdf.war
    sandbox/examples/src/main/resources/gemfire/springtravel-datamodel.jar
    sandbox/examples/src/main/resources/swf-booking-mvc.war' HEAD

popd

echo size after cleaning history:
du -h -d 0 || echo du depth arg not supported here
