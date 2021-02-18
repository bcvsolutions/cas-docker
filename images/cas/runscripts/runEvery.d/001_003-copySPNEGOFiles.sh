#!/bin/bash
echo "[$0] Copying SPNEGO configuration files...";

if [ ! -z "${DOCKER_SKIP_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_CONFIGURATION is defined, skipping this script.";
  exit;
fi

if [[ "$CAS_SPNEGO_ENABLED" != "true" ]]; then
  echo "[$0] SPNEGO authentication is not enabled, skipping this script.";
  exit;
fi

cd "/casstart/spnego/"
echo "[$0] Copying the keytab...";
cp file.keytab /etc/cas/config/file.keytab
chown tomcat:tomcat /etc/cas/config/file.keytab
chmod 600 /etc/cas/config/file.keytab

echo "[$0] Copying the login.conf file...";
cp login.conf /etc/cas/config/login.conf
chown tomcat:tomcat /etc/cas/config/login.conf

echo "[$0] Copying the krb5.conf file...";
cp krb5.conf /etc/krb5.conf
chown tomcat:tomcat /etc/krb5.conf













