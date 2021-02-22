# cas-docker
Docker images for Apereo CAS docker container

CAS docker image is built atop BCV's Tomcat image. All additional modules, connectors, configuration, etc. are supposed to be built atop existing docker image, effectively creating new docker image.

## Directory structure
- **compose/** - contains simple/sample docker-compose files for image from this repo.
- **images/** - contains sources for building docker images.

## Additional info
- Release tags on this repository correspond to release tags on individual images.
- See **README.md** in [images/cas/](images/cas/) to get more information about specific docker image.
- See **README.md** in [compose/](compose/) for compose YAML files and for starting images as a part of the infrastructure.

