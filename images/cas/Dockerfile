FROM repo.iamappliance.com:8443/bcv-tomcat:9.0.41-r1

ENV CAS_VERSION 6.2.8.1

ENV TOMCAT_BASE /opt/tomcat/current/
ENV CAS_BASE /etc/cas/
ENV CAS_CONFIG /etc/cas/config/
ENV CAS_SAML /etc/cas/saml/
ENV CAS_START /casstart/

# install sw and link it where necessary
RUN yum install -y krb5-workstation krb5-libs krb5-auth-dialog xmlstarlet openssl dos2unix jq which && \
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

# create CAS and Tomcat config & data structures
RUN mkdir -pv $CAS_CONFIG && \
		chmod -v 750 $CAS_CONFIG && \
		chown -R tomcat $CAS_CONFIG && \
		mkdir -pv $CAS_SAML && \
		chmod -v 750 $CAS_SAML && \
		chown -R tomcat $CAS_SAML && \
		cd $TOMCAT_BASE && \
		chown -R tomcat webapps/ work/ temp/ logs/

# We just copy the war into the container here.
COPY "dropin/cas-$CAS_VERSION.war" "$TOMCAT_BASE/webapps/cas.war"

# Copy CAS configuration template and tools
COPY "dropin/cas.TPL.properties" "dropin/jwk-gen.jar" "$CAS_START"

# finally, copy over the runscripts; this adds our runscripts to the Tomcat baseimage
COPY runscripts "$RUNSCRIPTS_PATH/"
RUN find "$RUNSCRIPTS_PATH/" -name "*.sh" -exec chmod -v u+x {} \;

CMD ["/bin/bash","-c","$RUNSCRIPTS_PATH/run.sh"]

EXPOSE 8009/tcp
EXPOSE 8080/tcp

# For volumes documentation, see README.md.
