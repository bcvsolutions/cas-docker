#!/bin/bash
echo "[$0] Updating CAS application configuration...";

if [ ! -z "${DOCKER_SKIP_CAS_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_CAS_CONFIGURATION is defined, skipping this script.";
  exit;
fi

cd "$CAS_CONFIG";

cp "$CAS_START/cas.TPL.properties" cas.properties;

# Take variables that were set and (re)place them in the config file.

# HOSTNAME CONFIG
if [ -z "${CAS_SERVER_NAME}" ]; then
  echo "[$0] CAS_SERVER_NAME not set, using default from the template. - EMPTY!!!";
else
  sed -i "s#.*cas.server.name=.*#cas.server.name=$CAS_SERVER_NAME#" cas.properties;
fi
if [ -z "${CAS_SERVER_PREFIX}" ]; then
  echo "[$0] CAS_SERVER_PREFIX not set, using default from the template '\${cas.server.name}/cas'.";
else
  sed -i "s#.*cas.server.prefix=.*#cas.server.prefix=$CAS_SERVER_PREFIX#" cas.properties;
fi

if [ -z "${CAS_SERVICES_REGISTRY_JSON_LOCATION}" ]; then
  echo "[$0] CAS_SERVICES_REGISTRY_JSON_LOCATION not set, using default from the template '/conf/cas/services'.";
else
  sed -i "s#.*cas.service-registry.json.location=.*#cas.service-registry.json.location=file:$CAS_SERVICES_REGISTRY_JSON_LOCATION#" cas.properties;
fi

# LDAP[0] CONFIG
if [ -z "${CAS_LDAP_0_TYPE}" ]; then
  echo "[$0] CAS_LDAP_0_TYPE not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].type=.*#cas.authn.ldap\[0\].type=$CAS_LDAP_0_TYPE#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_LDAP_URL}" ]; then
  echo "[$0] CAS_LDAP_0_LDAP_URL not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].ldapUrl=.*#cas.authn.ldap\[0\].ldapUrl=$CAS_LDAP_0_LDAP_URL#" cas.properties;
  sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].ldapUrl=.*#cas.authn.attribute-repository.ldap\[0\].ldapUrl=$CAS_LDAP_0_LDAP_URL#" cas.properties;
  sed -i "s#.*cas.authn.ldap\[0\].principalAttributeList=.*#cas.authn.ldap[0].principalAttributeList=mobile,givenName,mail,sn,uid,iamUserStatus,cn#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_USE_SSL}" ]; then
  echo "[$0] CAS_LDAP_0_USE_SSL not set, using default from the template - false.";
else
  sed -i "s#.*cas.authn.ldap\[0\].usessl=.*#cas.authn.ldap\[0\].usessl=$CAS_LDAP_0_USE_SSL#" cas.properties;
  sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].useSsl=.*#cas.authn.attribute-repository.ldap\[0\].useSsl=$CAS_LDAP_0_USE_SSL#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_SUBTREE_SEARCH}" ]; then
  echo "[$0] CAS_LDAP_0_SUBTREE_SEARCH not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].subtreeSearch=.*#cas.authn.ldap\[0\].subtreeSearch=$CAS_LDAP_0_SUBTREE_SEARCH#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_BASE_DN}" ]; then
  echo "[$0] CAS_LDAP_0_BASE_DN not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].baseDn=.*#cas.authn.ldap\[0\].baseDn=$CAS_LDAP_0_BASE_DN#" cas.properties;
  sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].baseDn=.*#cas.authn.attribute-repository.ldap\[0\].baseDn=$CAS_LDAP_0_BASE_DN#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_SEARCH_FILTER}" ]; then
  echo "[$0] CAS_LDAP_0_SEARCH_FILTER not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].search-filter=.*#cas.authn.ldap\[0\].search-filter=$CAS_LDAP_0_SEARCH_FILTER#" cas.properties;
  sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].search-filter=.*#cas.authn.attribute-repository.ldap\[0\].search-filter=$CAS_LDAP_0_SEARCH_FILTER#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_BIND_DN}" ]; then
  echo "[$0] CAS_LDAP_0_BIND_DN not set, using default from the template - EMPTY!!!.";
else
  sed -i "s#.*cas.authn.ldap\[0\].bindDn=.*#cas.authn.ldap\[0\].bindDn=$CAS_LDAP_0_BIND_DN#" cas.properties;
  sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].bindDn=.*#cas.authn.attribute-repository.ldap\[0\].bindDn=$CAS_LDAP_0_BIND_DN#" cas.properties;
fi

if [ -z "${CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE}" ]; then
  echo "[$0] CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE not set, using default from the template - EMPTY!!!.";
else
  if [ -f "${CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE}" ]; then
    ldappass=$(grep -o '".*"' "$CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE" | sed 's/"//g');
    sed -i "s#.*cas.authn.ldap\[0\].bindCredential=.*#cas.authn.ldap\[0\].bindCredential=$ldappass#" cas.properties;
    sed -i "s#.*cas.authn.attribute-repository.ldap\[0\].bindCredential=.*#cas.authn.attribute-repository.ldap\[0\].bindCredential=$ldappass#" cas.properties;
  else
    echo "[$0] CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE not readable, using default password from the template - EMPTY!!!.";
  fi
fi

# CAS CLIENT CONFIG

if [ -z "${CAS_CLIENT_VALIDATOR_TYPE}" ]; then
  echo "[$0] CAS_CLIENT_VALIDATOR_TYPE not set, using default from the template 'CAS30'.";
else
  sed -i "s#.*cas.client.validator-type=.*#cas.client.validator-type=$CAS_CLIENT_VALIDATOR_TYPE#" cas.properties;
fi

if [ -z "${CAS_LOGOUT_FOLLOW_SERVICE_REDIRECTS}" ]; then
  echo "[$0] CAS_LOGOUT_FOLLOW_SERVICE_REDIRECTS not set, using default from the template 'true'.";
else
  sed -i "s#.*cas.logout.follow-service-redirects=.*#cas.logout.follow-service-redirects=$CAS_LOGOUT_FOLLOW_SERVICE_REDIRECTs#" cas.properties;
fi

# CAS TICKET TIMEOUT CONFIG

if [ -z "${CAS_TGT_IDLE_TIMEOUT}" ]; then
  echo "[$0] CAS_TGT_IDLE_TIMEOUT not set, using default from the template '28800'.";
else
  sed -i "s#.*cas.ticket.tgt.timeout.max-time-to-live-in-seconds=.*#cas.ticket.tgt.timeout.max-time-to-live-in-seconds=$CAS_TGT_IDLE_TIMEOUT#" cas.properties;
fi

if [ -z "${CAS_TGT_HARD_TIMEOUT}" ]; then
  echo "[$0] CAS_TGT_HARD_TIMEOUT not set, using default from the template '43200'.";
else
  sed -i "s#.*cas.ticket.tgt.hard-timeout.time-to-kill-in-seconds=.*#cas.ticket.tgt.hard-timeout.time-to-kill-in-seconds=$CAS_TGT_HARD_TIMEOUT#" cas.properties;
fi

if [ -z "${CAS_TICKET_NUMBER_OF_USES}" ]; then
  echo "[$0] CAS_TICKET_NUMBER_OF_USES not set, using default from the template '25'.";
else
  sed -i "s#.*cas.ticket.st.number-of-uses=.*#cas.ticket.st.number-of-uses=$CAS_TICKET_NUMBER_OF_USES#" cas.properties;
fi

if [ -z "${CAS_ST_HARD_TIMEOUT}" ]; then
  echo "[$0] CAS_ST_HARD_TIMEOUT not set, using default from the template '900'.";
else
  sed -i "s#.*cas.ticket.st.time-to-kill-in-seconds=.*#cas.ticket.st.time-to-kill-in-seconds=$CAS_ST_HARD_TIMEOUT#" cas.properties;
fi

# CUSTOM FRONTED CHANGES
if [ -z "${CAS_CUSTOM_FRONTEND}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND not set, using default from the template 'false'.";
else
  sed -i "s#.*cas.custom.frontend.iam=.*#cas.custom.frontend.iam=$CAS_CUSTOM_FRONTEND#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_TITLE}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_TITLE not set, using default from the template 'IAM Centralni login'.";
else
  sed -i "s#.*cas.custom.frontend.title=.*#cas.custom.frontend.title=$CAS_CUSTOM_FRONTEND_TITLE#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_FOOTER_TEXT}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_FOOTER_TEXT not set, using default from the template - EMPTY!!!";
else
  sed -i "s#.*cas.custom.frontend.footer-text=.*#cas.custom.frontend.footer-text=$CAS_CUSTOM_FRONTEND_FOOTER_TEXT#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_FOOTER_LINK}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_FOOTER_LINK not set, using default from the template 'https://www.bcvsolutions.eu'.";
else
  sed -i "s#.*cas.custom.frontend.footer-link=.*#cas.custom.frontend.footer-link=$CAS_CUSTOM_FRONTEND_FOOTER_LINK#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_FOOTER_LINKTEXT}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_FOOTER_LINKTEXT not set, using default from the template 'BCV solutions'.";
else
  sed -i "s#.*cas.custom.frontend.footer-linktext=.*#cas.custom.frontend.footer-linktext=$CAS_CUSTOM_FRONTEND_FOOTER_LINKTEXT#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_LOGO_LINK}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_LOGO_LINK not set, using default from the template 'https://www.bcvsolutions.eu'.";
else
  sed -i "s#.*cas.custom.frontend.logolink=.*#cas.custom.frontend.logolink=$CAS_CUSTOM_FRONTEND_LOGO_LINK#" cas.properties;
fi

if [ -z "${CAS_CUSTOM_FRONTEND_PASSWORDRESET_DISPLAY}" ]; then
  echo "[$0] CAS_CUSTOM_FRONTEND_PASSWORDRESET_DISPLAY not set, using default from the template 'false'.";
else
  sed -i "s#.*cas.custom.frontend.passwordReset.display=.*#cas.custom.frontend.passwordReset.display=$CAS_CUSTOM_FRONTEND_PASSWORDRESET_DISPLAY#" cas.properties;
fi

# AD SSO CONFIG
if [ -z "${CAS_KERBEROS_DEBUG}" ]; then
  # if no kerberos debug var is set, set it to false
  CAS_KERBEROS_DEBUG="false";
fi
if [[ "$CAS_SPNEGO_ENABLED" != "true" ]]; then
  echo "[$0] CAS_SPNEGO_ENABLED not set to true, using default from the template (DISABLED).";
else
cat << EOF >> cas.properties


### SPNEGO CONFIGURATION

# needed to allow local sign in if SSO is not available
cas.authn.spnego.supported-browsers=MSIE,Trident,Firefox,AppleWebKit
cas.authn.spnego.send401-on-authentication-failure=true
cas.authn.spnego.ntlm-allowed=false
cas.authn.spnego.ntlm=false
cas.authn.spnego.name=KERBEROS_SPNEGO

cas.authn.spnego.system.kerberos-conf=file:/etc/krb5.conf
cas.authn.spnego.system.login-conf=file:/etc/cas/config/login.conf
cas.authn.spnego.system.kerberos-realm=$CAS_KERBEROS_REALM
cas.authn.spnego.system.kerberos-debug=$CAS_KERBEROS_DEBUG
cas.authn.spnego.system.use-subject-creds-only=true
cas.authn.spnego.system.kerberos-kdc=$CAS_KERBEROS_KDC

cas.authn.spnego.host-name-client-action-strategy=hostnameSpnegoClientAction
cas.authn.spnego.alternative-remote-host-attribute=alternateRemoteHeader
cas.authn.spnego.ips-to-check-pattern=.+
cas.authn.spnego.host-name-pattern-string=.+
cas.webflow.autoconfigure=true
cas.authn.spnego.properties[0].cache-policy=600
cas.authn.spnego.properties[0].timeout=300000
cas.authn.spnego.properties[0].jcifs-service-principal=$CAS_KERBEROS_SERVICE_PRINCIPAL
EOF
fi
