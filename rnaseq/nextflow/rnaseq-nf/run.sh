#/bin/bash

echo "Grabbing a rnaseq job via the ahab CLI..."
export job_json=$(ahab job get --job_type rnaseq)
export id=$(echo $job_json | jq -r '.id')

## Input Parameters
export transcriptome=$(echo $job_json | jq -r '.inputs.transcriptome')
export reads=$(echo $job_json | jq -r '.inputs.reads')
export outdir=$(echo $job_json | jq -r '.inputs.outdir')
export multiqc=$PWD/multiqc

echo "Running Nextflow pipeline..."
nextflow run .

if [ $? -eq 0 ]; then
    echo "Nextflow pipeline completed. Updating ahab job status..."
    ahab job update --id $id --status "COMPLETE" --body '{"outputs": {"results": "/mnt/datalake/samples/ggal/results"}}'
else
    echo "Nextflow pipeline failed. Updating ahab job status..."
    ahab job update --id $id --status "FAILED" --body '{"outputs": {"results": "/mnt/datalake/samples/ggal/results"}}'
fi


