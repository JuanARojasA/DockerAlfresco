FROM centos:centos7.7.1908

#WGET Download
ENV TOMCAT_URL=https://downloads.apache.org/tomcat/tomcat-8/v8.5.54/bin/apache-tomcat-8.5.54.tar.gz
ENV ALFRESCO_URL=https://download.alfresco.com/cloudfront/release/community/201911-GA-build-368/alfresco-content-services-community-distribution-6.2.0-ga.zip
ENV ALFRESCO_SEARCH_URL=https://download.alfresco.com/cloudfront/release/community/SearchServices/1.4.0/alfresco-search-services-1.4.0.zip
ENV SSL_TOOL_URL=https://github.com/Alfresco/alfresco-ssl-generator/archive/master.zip

ENV LIBREOFF_URL=https://download.documentfoundation.org/libreoffice/stable/6.3.5/rpm/x86_64/LibreOffice_6.3.5_Linux_x86-64_rpm.tar.gz
ENV IMGMGK_URL=https://imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-7.0.10-10.x86_64.rpm
ENV IMGMGK_LIB_URL=https://imagemagick.org/download/linux/CentOS/x86_64/ImageMagick-libs-7.0.10-10.x86_64.rpm
ENV POSTGRSQL_JAR_URL=https://jdbc.postgresql.org/download/postgresql-42.2.6.jre6.jar

#Directories Variables
ENV ALFRESCO_HOME=/opt/alfresco
ENV TOMCAT_HOME=/opt/alfresco/tomcat
ENV SOLR_HOME=/opt/solr6

#Packages installation
RUN yum -y update && yum -y install java-11-openjdk-devel lsof epel-release wget openssl unzip
RUN yum clean all

#Tomcat Configuration
RUN mkdir -p ${TOMCAT_HOME} \
    && useradd -s /bin/nologin -d ${TOMCAT_HOME} tomcat \
    && wget ${TOMCAT_URL} && tar -zxvf apache-tomcat*.tar.gz && mv apache-tomcat*/* ${TOMCAT_HOME}/ \
    && rm -rf apache-tomcat* && mkdir -p ${TOMCAT_HOME}/shared/classes ${TOMCAT_HOME}/shared/lib

#Alfresco Community Configuration
RUN wget ${ALFRESCO_URL} && unzip alfresco-content*.zip && rm -f alfresco-content*.zip \
    && mv alfresco-content*/* ${ALFRESCO_HOME} && rm -rf alfresco-content* \
    && mv ${ALFRESCO_HOME}/web-server/webapps/* ${TOMCAT_HOME}/webapps/ \
    && mv ${ALFRESCO_HOME}/web-server/lib/* ${TOMCAT_HOME}/lib/ \
    && rm -rf ${TOMCAT_HOME}/webapps/*/

#Solr
RUN wget ${ALFRESCO_SEARCH_URL} && unzip alfresco-search*.zip \
    && mkdir -p ${SOLR_HOME} && mv alfresco-search*/* ${SOLR_HOME}/ \
    && rm -rf alfresco-search*

#Keystore
COPY assets/generate_keystores.sh ~/
RUN sh generate_keystores.sh

#RUN wget ${SSL_TOOL_URL} \
#    && unzip master.zip && cd alfresco-ssl-generator-master/ssl-tool \
#    && ./run.sh && mv keystores/alfresco/* ${ALFRESCO_HOME}/alf_data/keystore/ \
#    && mkdir ${SOLR_HOME}/keystore && mv keystores/solr/* ${SOLR_HOME}/keystore/ \
#    && ln -s ${SOLR_HOME}/keystore ${SOLR_HOME}/solr/keystore \
#    && ln -s ${SOLR_HOME}/keystore ${SOLR_HOME}/solrhome/keystore \
#    && cd

#Copy SolrCore properties SSL
COPY assets/solrcore.properties ${SOLR_HOME}/solrhome/templates/rerank/conf/
COPY assets/solrhome/alfresco/conf/solrcore.properties ${SOLR_HOME}/solrhome/alfresco/conf/
COPY assets/solrhome/archive/conf/solrcore.properties ${SOLR_HOME}/solrhome/archive/conf/

# Install Modules
COPY assets/apply_amps.sh ${ALFRESCO_HOME}/bin/
RUN sh ${ALFRESCO_HOME}/bin/apply_amps.sh

# Install LibreOffice
RUN wget ${LIBREOFF_URL} && tar -xvf LibreOffice_6.3.5_Linux_x86-64_rpm.tar.gz \
    && mv LibreOffice_6.3.5.2_Linux_x86-64_rpm LibreOffice \
    && yum -y localinstall LibreOffice/RPMS/*.rpm \
    && rm -rf LibreOffice*

# Install ImageMagick
RUN wget ${IMGMGK_LIB_URL} && wget ${IMGMGK_URL} \
    && yum -y localinstall ImageMagick-libs-7.0.10-10.x86_64.rpm ImageMagick-7.0.10-10.x86_64.rpm \
    && rm -rf ImageMagick*

# Install PDF-Renderer
RUN tar -xvf ${ALFRESCO_HOME}/alfresco-pdf-renderer/alfresco-pdf-renderer-1.1-linux.tgz -C ${ALFRESCO_HOME}/alfresco-pdf-renderer/

# Install PostgreSQL JAR
RUN wget ${POSTGRSQL_JAR_URL} && mv postgresql*.jar ${TOMCAT_HOME}/lib/

COPY assets/alfresco-global.properties ${TOMCAT_HOME}/shared/classes/
COPY assets/shared.properties ${SOLR_HOME}/solrhome/conf/
COPY assets/run.sh run.sh
COPY assets/catalina.properties ${TOMCAT_HOME}/conf/
COPY assets/server.xml ${TOMCAT_HOME}/conf/

RUN mkdir -p ${TOMCAT_HOME}/modules/share ${TOMCAT_HOME}/modules/platform

RUN chmod +x run.sh && chown -RH tomcat: ${TOMCAT_HOME} && chmod +x ${TOMCAT_HOME}/bin/*.sh 

RUN rm -f ${SOLR_HOME}/solrhome/keystore && cp -rf ${SOLR_HOME}/solrhome/* ${SOLR_HOME}/

#Expose ports
EXPOSE 8080 8983 5432
#8983 For Solr
#3306 For PostgreSQL Connector

CMD [ "run" ]
ENTRYPOINT [ "./run.sh" ]
