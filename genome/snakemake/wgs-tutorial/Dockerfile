FROM snakemake/snakemake:stable
## Based on: https://snakemake.readthedocs.io/en/stable/tutorial
USER root

ADD environment.yaml .

## Make mamba environment
RUN mamba create -n snakemake-tutorial --clone snakemake; \
    mamba env update -n snakemake-tutorial -f environment.yaml;
RUN mkdir -p /tmp/conda
ENV CONDA_PKGS_DIRS /tmp/conda

## Install ahab CLI
RUN pip install \
    ahab-lib

## Copy pipeline files
RUN mkdir /pipeline
WORKDIR /pipeline
COPY Snakefile run.sh /pipeline/
COPY scripts/ /pipeline/scripts

## Activate mamba environment
SHELL ["/bin/bash", "-c"]
RUN echo "source activate snakemake-tutorial" > ~/.bashrc
SHELL ["/bin/bash", "-l", "-c"]

