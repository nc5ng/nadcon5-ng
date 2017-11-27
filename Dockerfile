FROM ubuntu:16.04

LABEL maintainer="akshmakov@gmail.com"

RUN apt-get update -y && \
    apt-get install 