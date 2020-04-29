#!/bin/bash
set -e

if [ "$1" == "run" ]
then
    bash /opt/alfresco/tomcat/bin/startup.sh &
	bash /opt/solr6/solr/bin/solr start -a "-Dcreate.alfresco.defaults=alfresco,archive -Dsolr.allow.unsafe.resourceloading=true" -force
	tail -f /opt/alfresco/tomcat/logs/catalina.out
else
	exec "$@"
fi