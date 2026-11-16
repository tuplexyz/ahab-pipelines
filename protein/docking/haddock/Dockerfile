FROM cford38/haddock:3-2026.5.0

RUN apt-get update && \
    apt-get install -y \
        curl \
        jq

RUN pip install ahab-lib


## Copy pipeline files into image
RUN mkdir /pipeline
COPY . /pipeline
RUN chmod +x /pipeline/run.sh /pipeline/bin/*.sh
WORKDIR /pipeline