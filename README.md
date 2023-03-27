# doxygen-docker

tutorial on how to use this : https://sumguy.com/install-use-doxygen-via-docker/

simple command line : docker run --rm -it -v ./source:/source -v ./output:/output -v ./Doxygen:/Doxygen ghcr.io/kingpin/doxygen-docker:latest

you will need to mount the source, outpuit and a Doxygen file.
