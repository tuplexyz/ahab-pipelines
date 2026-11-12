FROM snakemake/snakemake:v8.13.0
## Based on: https://snakemake.readthedocs.io/en/stable/tutorial
USER root

COPY environment.yaml /tmp/environment.yaml

## Install into the environment that is already on PATH at container runtime.
RUN mamba env update -p /opt/conda/envs/snakemake -f /tmp/environment.yaml && \
    mamba clean --all --yes

## Install ahab CLI
RUN pip install \
    ahab-lib

## Copy pipeline files
RUN mkdir /pipeline
WORKDIR /pipeline
COPY Snakefile run.sh /pipeline/
COPY scripts/ /pipeline/scripts
RUN chmod +x /pipeline/run.sh

