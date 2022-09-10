FROM alpine:latest

RUN apk --update --no-cache add doxygen graphviz git
    
CMD ["doxygen", "/Doxygen"]
