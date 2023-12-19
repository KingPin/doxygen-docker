
# Doxygen in Docker

tutorial on how to use this : https://sumguy.com/install-use-doxygen-via-docker/

simple command line : docker run --rm -it -v ./source:/source -v ./output:/output -v ./Doxygen:/Doxygen ghcr.io/kingpin/doxygen-docker:latest

you will need to mount the source, output and a Doxygen file.

available OS's : 

 - Alpine (using latest at time of build)
 - Debian (using latest stable-slim at time of build)

Available tags :

 - **latest**
	 - uses alpine as the base container along with latest available doxygen at time of build
 - **alpine**
	 - uses alpine as the base container along with latest available doxygen at time of build
 - **alpine-x.x.x**
	 - uses alpine as the base container along with a specific version of doxygen (usually latest packaged at time of build)
	 - e.g.
		 - alpine-1.9.8
		 - see following pages for list
			 - https://hub.docker.com/r/kingpin/doxygen-docker/tags
			 - https://github.com/KingPin/doxygen-docker/pkgs/container/doxygen-docker
 - **debian**
	 - uses debian as the base container along with latest available doxygen at time of build
 - **debian-x.x.x**
	 - uses debian as the base container along with a specific version of doxygen (usually latest packaged at time of build)
	 - e.g.
		 - debian-1.9.4
		 - see following pages for list
			 - https://hub.docker.com/r/kingpin/doxygen-docker/tags
			 - https://github.com/KingPin/doxygen-docker/pkgs/container/doxygen-docker	
