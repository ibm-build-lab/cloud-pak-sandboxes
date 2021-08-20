FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y curl && \
    apt-get install -y jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD cp-schematic-workspaces/ workspaces/