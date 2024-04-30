FROM mambaorg/micromamba
## Based on: https://github.com/nextflow-io/rnaseq-nf/blob/master/docker/Dockerfile

RUN \
   micromamba install -y -n base -c defaults -c bioconda -c conda-forge \
      salmon=1.10.2 \
      fastqc=0.12.1 \
      multiqc=1.17 \
      python=3.11 \
      typing_extensions \
      importlib_metadata \
      procps-ng \
   && micromamba clean -a -y

ENV PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"
USER root

## New stuff for ahab...
RUN apt-get update && \
    apt-get install -y \
        curl \
        jq

## Install pipx, ahab CLI
RUN pip install \
    ahab-lib

## Install Nextflow
RUN cd /bin && \
    curl -s https://get.nextflow.io | bash

## Copy pipeline files into image
RUN mkdir /pipeline
COPY . /pipeline
WORKDIR /pipeline