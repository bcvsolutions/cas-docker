# CAS image
Image built atop BCV's Tomcat image with Apache Tomcat 9.0.x version.
You can find our Tomcat Docker image [here](https://github.com/bcvsolutions/tomcat-docker). This image is referenced as a "baseimage" throughout this text.

## Image versioning
This image is versioned by CAS version. The underlying Tomcat version is not mentioned since CAS is distributed as a whole application stack.

Naming scheme is pretty simple: **bcv-cas:CAS_VERSION-rIMAGE_VERSION**.
- Image name is **bcv-cas**.
- **CAS_VERSION** is a version of CAS in the image.
- **IMAGE_VERSION** is an image release version written as a serial number, starting at 0. When images have the same CAS versions but different image versions it means there were some changes in the image itself (setup scripts, etc.) but application itself did not change.

Example
```
bcv-cas:6.2.4-r0    // first release of CAS 6.2.4 image
bcv-cas:6.2.4-r2    // third release of CAS 6.2.4 image
bcv-cas:6.3.0-r0    // first release of CAS 6.3.0 image
bcv-cas:latest      // nightly build
```

## Building
To build a new CAS image, put the application WAR archive into **dropin/cas.war**
Then cd to the directory which contains the Dockerfile and issue `docker build --no-cache -t <image tag here> ./`.

The build process:
1. Pulls **bcv-tomcat:some-version** image.
1. Installs necessary tooling - openssl, xmlstarlet, kerberos tools etc.
1. Secures Tomcat installation, namely:
  1. Disables shutdown port.
  1. Disables directory listings.
  1. Removes all Tomcat management apps.
1. Copies cas.war with given application version into the container. If you need other version of the app, you **have to build a new image**.
1. Copies additional runscripts into the container. Those runscripts generate CAS configuration. For explanation of runscripts, see Tomcat baseimage documentation.
1. Creates CAS configuration directory structure **/etc/cas/...**.

## Use
Image contains some defaults.
- STDOUT/STDERR logging, logs available with `docker logs CONTAINER`.
- Xms512M
- Xmx1024M

After it is started up, you can navigate to http://yourserver:8080/cas. CAS itself is a bare application and needs to be connected with other applications to do anything useful.

### Minimal mandatory parameters for deployments
Those parameters have no defaults and when left unset, CAS will not start at all.


## Container startup and hooks
Container start leverages existing hooks infrastructure as provided by the Tomcat baseimage - **run.sh**, **runOnce.sh**, **runEvery.sh**, **startTomcat.sh** and their respective **.d/** directories. For more information about runscripts structure, see Tomcat baseimage doc.

CAS image adds its own scripts there:
- **runEvery.d/001_000-generateTruststore.sh** - This script was superseded by similar baseimage functionality.
- **runEvery.d/001_001-createCASAppconfig.sh** - Creates the cas.properties file which defines CAS behavior.
- **runEvery.d/001_002-copyCASServiceDefinitions.sh** - Copies the default services for CAS.
- **runEvery.d/001_003-generateKeys.sh** - Generates the signing and encryption keys used by CAS.
- **runEvery.d/001_004-copySPNEGOFiles.sh** - Copies the SPNEGO files (config and keytab).

## Container shutdown
See Tomcat baseimage doc. CAS is very swift when shutting down, the default STOP_TIMEOUT should be more than enough.

## Environment variables
You can pass a number of environment variables into the container. All Tomcat baseimage environment variables are supported - see the baseimage doc. Apart from that, CAS configuration is set based on these environment variables.

If you need more to set more properties that defined here, they must be added to relevant scripts. A quick workaround 
is to mount the cas.properties file to /etc/cas/config/cas.properties.
- **CAS_SERVER_NAME** - The hostname of the CAS server, e. g., 'https://company.com', property in cas.properties 'cas.server.name'. **Default: not set**.
- **CAS_SERVER_PREFIX** - The actual link at which CAS is available, e. g., 'https://company.com/cas', property in cas.properties 'cas.server.prefix'. **Default: '${cas.server.name}/cas'**.
- **CAS_SERVICES_REGISTRY_JSON_LOCATION** - The location of the JSON services definitions, property in cas.properties 'cas.service-registry.json.location'. **Default: '/conf/cas/services'**.

### LDAP configuration
LDAP is used as the source of data about users by CAS. By default, all properties related to it are not set (commented out) because CAS **will not start if LDAP is defined but unavailable**. 

- **CAS_LDAP_0_TYPE** - The type of LDAP connection, property in cas.properties 'cas.authn.ldap[0].type'. Recommended 'DIRECT'. **Default: not set**.
- **CAS_LDAP_0_LDAP_URL** - The URL of LDAP in LDAP format with port, e. g., 'ldap://openldap:389', property in cas.properties 'cas.authn.ldap[0].ldapUrl='. **Default: 'not set'**.
- **CAS_LDAP_0_USE_SSL** - Set whether SSL should be used or not for LDAP - if using port 389, set 'false', if 636, set true, property in cas.properties 'cas.authn.ldap[0].usessl'. **Default: 'not set'**.
- **CAS_LDAP_0_SUBTREE_SEARCH** - Set whether subtree search should be used, set to true, property in cas.properties 'cas.authn.ldap[0].subtreeSearch'. **Default: 'not set'**.
- **CAS_LDAP_0_BASE_DN** - The starting point of search, property in cas.properties 'cas.authn.ldap[0].baseDn'. **Default: 'not set'**.
- **CAS_LDAP_0_SEARCH_FILTER** - Define the search filter, property in cas.properties 'cas.authn.ldap[0].searchFilter'. Recommended 'cn={user}'. **Default: 'not set'**.
- **CAS_LDAP_0_BIND_DN** - The DN of the user CAS uses to read LDAP, property in cas.properties 'cas.authn.ldap[0].bindDn'. **Default: 'not set'**.
- **CAS_LDAP_0_BIND_CREDENTIAL_PASSFILE** - The name of the file containing the password for the user account defined above, property in cas.properties 'cas.authn.ldap[0].bindCredential'. Use 'ldap.pwfile' and mount this file. **Default: 'not set'**.
- **CAS_LDAP_0_DN_FORMAT** - Define the DN format, property in cas.properties 'cas.authn.ldap[0].dn-format'. Recommended: 'cn=%s,ou=users,dc=iam,dc=cz'. **Default: 'not set'**.

### CAS client configuration for CzechIdM
- **CAS_CLIENT_VALIDATOR_TYPE** - Set the type of validator used by CAS client, property in cas.properties 'cas.client.validator-type'. **Default: 'CAS30'**.
- **CAS_TICKET_NUMBER_OF_USES** - Set the ticket expiration policy, property in cas.properties 'cas.ticket.st.number-of-uses'. **Default: '25'**.
- **CAS_LOGOUT_FOLLOW_SERVICE_REDIRECTS** - Allow logout redirects defined in services, property in cas.properties 'cas.logout.follow-service-redirects'. **Default: 'true'**.
- **CAS_IDM_LOCATION** - This value is used to configure the default service definition for CzechIdM. **Default: 'not set'**.

### Custom frontend changes
- **CAS_CUSTOM_FRONTEND** - Set whether custom BCV frontend design should be used, property in cas.properties 'cas.custom.frontend.iam'. **Default: 'false'**.
- **CAS_CUSTOM_FRONTEND_TITLE** - Set the title of the CAS login page, use Unicode to write special characters, e. g., "Centr\\u00E1ln\\u00ED login" for "Centrální login". Notice that backslashes must be escaped. Property in cas.properties 'cas.custom.frontend.title'. **Default: 'IAM Centr\u00E1ln\u00ED login'**.
- **CAS_CUSTOM_FRONTEND_FOOTER_TEXT** - Set the text shown in the footer, property in cas.properties 'cas.custom.frontend.footer-text'. **Default: 'not set'**.
- **CAS_CUSTOM_FRONTEND_FOOTER_LINK** - Set the URL of the link shown in the footer, property in cas.properties 'cas.custom.frontend.footer-link'. **Default: 'https://www.bcvsolutions.eu'**.
- **CAS_CUSTOM_FRONTEND_FOOTER_LINKTEXT** - Set the text of the link shown in the footer, property in cas.properties 'cas.custom.frontend.footer-linktext'. **Default: 'BCV solutions'**.
- **CAS_CUSTOM_FRONTEND_LOGO_LINK** - Set the URL of the logo, property in cas.properties 'cas.custom.frontend.logolink'. **Default: 'https://www.bcvsolutions.eu'**.

### SPNEGO authentication
- **CAS_SPNEGO_ENABLED** - Set SPNEGO should be enabled. This will set some static properties necessary for SPNEGO to work. **Default: 'false'**.
- **CAS_KERBEROS_REALM** - Set the Kerberos realm, property in cas.properties 'cas.authn.spnego.system.kerberos-realm'. **Default: 'not set'**.
- **CAS_KERBEROS_DEBUG** - Enable Kerberos debug mode, property in cas.properties 'cas.authn.spnego.system.kerberos-debug'. **Default: 'false'**.
- **CAS_KERBEROS_KDC** - Set the Kerberos KDC URL, property in cas.properties 'cas.authn.spnego.system.kerberos-kdc'. Multiple KDCs can be set, separate them by space ' '.**Default: 'not set'**.
- **CAS_KERBEROS_SERVICE_PRINCIPLE** - Set the Kerberos service principle name, property in cas.properties 'cas.authn.spnego.properties[0].jcifs-service-principal'. **Default: 'not set'**.

## Mounted files and volumes
- Optional
  - CAS configuration file
    - This file contains all configuration of CAS. See [here](https://apereo.github.io/cas/6.2.x/configuration/Configuration-Properties.html) for more details.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./cas.properties
          target: /etc/cas/config/cas.properties
          read_only: true
      ```

  - Trusted certificates directory
    - See 000_002-generateJavaTruststore.sh script documentation in the baseimage doc.
    - Without this directory mounted, CAS will not trust any SSL certificates. This effectively prevents CAS to securely connect to other systems. Nowadays, it is simply dangerous to run all communication in plaintext, so populating and mounting this directory is highly recommended.
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./certs
          target: /casstart/trustcert
          read_only: true
      ```

  - CAS services
    - CAS uses JSON files as sources for definitions of services which are configured to use CAS as an identity provider. The files should be in this folder. This is a shared volume because it can be populated by CAS Management.
    - Example
      ```yaml
      volumes:
        - 'cas_services:/conf/cas/services'
      ```

  - SPNEGO configuration files and the keytab
    - If you want to use SPNEGO authentication (SSO with MS AD), you need to supply a folder which contains the generated keytab file (file.keytab), the krb5.conf file and the login.conf file. 
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./spnego
          target: /casstart/spnego
          read_only: true
      ```
## Forbidden variables
The same variables as for Tomcat baseimage.

## Hacking away
See Tomcat baseimage doc.

