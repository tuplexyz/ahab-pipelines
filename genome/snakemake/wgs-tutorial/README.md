# WGS pipeline for _ahab_ 🦑

This pipeline is based on the example [`wgs-tutorial`](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html) pipeline with modifications to run in the _ahab_ system.

## Job inputs

Submit a `wgs` job with `inputs.outdir` set to a unique, writable output directory.
`inputs.inputdir` is optional and defaults to `/mnt/datalake/samples/sm_wgs/inputs`.
The input directory must contain `genome.fa`, its BWA index files (`.amb`, `.ann`,
`.bwt`, `.pac`, `.sa`), and `samples/A.fastq` and `samples/B.fastq`. The tutorial
analyzes samples A and B; sample C is not included in the workflow.

The output directory must be distinct for each job. The worker reports `COMPLETE`
or `FAILED` to the API, and exits nonzero if the workflow or status update fails.
The worker uses one CPU to match the current AHAB WGS job template; these
resources are intended for the small tutorial dataset, not production-scale WGS.

## Build the Docker image
```bash
docker build --platform linux/amd64 -t tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.1 .
```

## Running the pipeline in the image locally
(Using a volume to simulate the data lake connection.)
```bash
docker run -v "$PWD/data:/mnt/datalake/samples/sm_wgs/inputs:ro" --rm -it --entrypoint bash --name ahab-snakemake-wgs-tutorial tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.1
```

## Push to Container Registry
```bash
docker push tuplexyz/ahab-snakemake-wgs-tutorial:v8.13.1
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