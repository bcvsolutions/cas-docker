FROM bcv-tomcat:9.0.41-r0

ENV CAS_VERSION 6.2.1
ENV TOMCAT_BASE /opt/tomcat/current
ENV CAS_BASE /etc/cas
ENV CAS_CONFIG /etc/cas/config
ENV CAS_SAML /etc/cas/saml
ENV CAS_START /casstart

# install sw and link it where necessary
RUN yum install -y krb5-workstation krb5-libs krb5-auth-dialog xmlstarlet openssl dos2unix which && \
		yum clean all

# harden tomcat config and clean tomcat-bundled webapps
RUN cd $TOMCAT_BASE/conf && \
		xmlstarlet ed -L \
		-u "/Server[@port='8005' and @shutdown='SHUTDOWN']/@port" -v "-1" \
		-a "//Connector[@port='8080']" -t attr -n maxSwallowSize -v "-1" \
		server.xml && \
		\
		xmlstarlet ed -L -N ns="http://xmlns.jcp.org/xml/ns/javaee" \
		-u "//ns:servlet/ns:servlet-name[text()='default']/../ns:init-param/ns:param-name[text()='showServerInfo']/../ns:param-value/text()" -v "false" \
		web.xml && \
		\
		rm -rf $TOMCAT_BASE/webapps/{examples,docs,ROOT,host-manager,manager} && \
		chown root:root -v $TOMCAT_BASE/webapps

# We just copy the war into the container here.
COPY dropin/cas.war $TOMCAT_BASE/webapps

# copy the configuration template
COPY dropin/cas.TPL.properties $CAS_START/

# finally, copy over the runscripts; this adds our runscripts to the Tomcat baseimage
COPY runscripts "$RUNSCRIPTS_PATH/"
RUN find "$RUNSCRIPTS_PATH/" -name "*.sh" -exec chmod -v u+x {} \;

# create CAS config & data structures
RUN mkdir -pv $CAS_CONFIG && \
		chmod -v 750 $CAS_CONFIG && \
		chgrp -Rv tomcat $CAS_CONFIG

# create CAS SAML config & data structures
RUN mkdir -pv $CAS_SAML && \
		chmod -v 750 $CAS_SAML && \
		chgrp -Rv tomcat $CAS_SAML

# change the owner of files to tomcat so that it can create its files
RUN cd $CAS_BASE && \
		chown -R tomcat $CAS_SAML

# change the owner of files to tomcat so that it can create its files
RUN cd $TOMCAT_BASE && \
		chown -R tomcat webapps/ work/ temp/ logs/

CMD ["/bin/bash","-c","$RUNSCRIPTS_PATH/run.sh"]

EXPOSE 8009/tcp
EXPOSE 8080/tcp

# For volumes documentation, see README.md.
