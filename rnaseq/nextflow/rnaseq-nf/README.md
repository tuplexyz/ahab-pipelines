# RNAseq-NF pipeline for _ahab_ 🦑

This pipeline is based on the example [`nextflow-nf`](https://github.com/nextflow-io/rnaseq-nf) pipeline with modifications to run in the _ahab_ system.

## Build the Docker image
```bash
docker build -t tuplexyz/ahab-rnaseq-nf:v1.2.1 .
```

## Running the pipeline in the image locally
(Using a volume to simulate the data lake connection.)
```bash
docker run -v $pwd/data:/mnt/datalake --rm -it --entrypoint bash --name ahab-rnaseq-nf tuplexyz/ahab-rnaseq-nf:v1.2.1
```

## Push to Container Registry
```bash
docker push tuplexyz/ahab-rnaseq-nf:v1.2.1
```

## Applying a pod manually for testing
```bash
## Login to Azure and get AKS credentials
az login
az aks get-credentials --resource-group <Resource Group> --name <AKS Name> --overwrite-existing
# az aks get-credentials --resource-group rg-ahab-dev-eastus-001 --name kub-ahab-dev-eastus-001 --overwrite-existing

## Apply YAML
kubectl apply -f rnaseq-nf.yaml

## Bash into a specific node
kubectl exec -it rnaseq-nf-test-00 -- /bin/bash
```