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
1. Installs necessary tooling - openssl, xmlstarlet, etc.
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

## Container startup and hooks
Container start leverages existing hooks infrastructure as provided by the Tomcat baseimage - **run.sh**, **runOnce.sh**, **runEvery.sh**, **startTomcat.sh** and their respective **.d/** directories. For more information about runscripts structure, see Tomcat baseimage doc.

CAS image adds its own scripts there:
- **runEvery.d/001_000-generateTruststore.sh** - This script was superseded by similar baseimage functionality.

## Container shutdown
See Tomcat baseimage doc. CAS is very swift when shutting down, the default STOP_TIMEOUT should be more than enough.

## Environment variables
All Tomcat baseimage environment variables are supported - see the baseimage doc.

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
  - AD keytab
    - If you want to use SPNEGO authentication (SSO with MS AD), you need to supply a generated keytab file. 
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./spnego/file.keytab
          target: /etc/cas/config/file.keytab
          read_only: true
      ```

  - krb5.conf
    - If you want to use SPNEGO authentication (SSO with MS AD), you need to supply a the krb5.conf file. 
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./spnego/krb5.conf
          target: /etc/cas/config/krb5.conf
          read_only: true
      ```

  - login.conf
    - If you want to use SPNEGO authentication (SSO with MS AD), you need to supply a the login.conf file. 
    - Example
      ```yaml
      volumes:
        - type: bind
          source: ./spnego/login.conf
          target: /etc/cas/config/login.conf
          read_only: true
      ```

## Forbidden variables
The same variables as for Tomcat baseimage.

## Hacking away
See Tomcat baseimage doc.

