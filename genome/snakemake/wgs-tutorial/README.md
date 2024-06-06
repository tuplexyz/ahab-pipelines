# WGS pipeline for _ahab_ 🦑

This pipeline is based on the example [`wgs-tutorial`](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html) pipeline with modifications to run in the _ahab_ system.

## Build the Docker image
```bash
docker build -t tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.0 .
```

## Running the pipeline in the image locally
(Using a volume to simulate the data lake connection.)
```bash
docker run -v $pwd/data:/mnt/datalake/samples/wgs-tutorial/ --rm -it --entrypoint bash --name ahab-snakemake-wgs-tutorial tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.0
```

## Push to Container Registry
```bash
docker push tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.0
```

## Applying a pod manually for testing
```bash
## Login to Azure and get AKS credentials
az login
az aks get-credentials --resource-group <Resource Group> --name <AKS Name> --overwrite-existing
# az aks get-credentials --resource-group rg-ahab-dev-eastus-001 --name kub-ahab-dev-eastus-001 --overwrite-existing

## Apply YAML
kubectl apply -f wgs-snakemake.yaml

## Bash into a specific node
kubectl exec -it wgs-snakemake-test-00 -- /bin/bash
```