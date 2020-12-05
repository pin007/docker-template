# docker-template

Template of simple docker repository.

## Makefile

The Makefile is a simple wrapper for building and publishing docker images.

The image name `IMAGE_NAME` is determined from directory name. The image tag `IMAGE_TAG` is determined from current 
git branch.  

Make variables can be overridden in `.env` file. This is mainly used for setting `REGISTRY`, `REGISTRY_USER`, 
`DOCKER_BUILD_ARGS`, `DOCKER_RUN_ARGS` or forcing `IMAGE_TAG`.
