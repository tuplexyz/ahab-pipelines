#/bin/bash

echo "Grabbing a wgs job via the ahab CLI..."
export job_json=$(ahab job get --job_type wgs)
export id=$(echo $job_json | jq -r '.id')

## Input Parameters
export inputdir=$(echo $job_json | jq -r '.inputs.inputdir')
export outdir=$(echo $job_json | jq -r '.inputs.outdir')
# export inputdir="/mnt/datalake/samples/wgs-tutorial/"
# export outdir="/mnt/datalake/samples/wgs-tutorial/output/"
export ncores=$(nproc)

## Make output directory
echo "Making output directory..."
mkdir -p $outdir

echo "Running Snakemake pipeline..."
snakemake --cores ${ncores} --config inputdir=${inputdir} outdir=${outdir}

if [ $? -eq 0 ]; then
    echo "Snakemake pipeline completed. Updating ahab job status..."
    ahab job update --id $id --status "COMPLETE" --body '{"outputs": {"results": "'${outdir}'"}}'
else
    echo "Snakemake pipeline failed. Updating ahab job status..."
    ahab job update --id $id --status "FAILED" --body '{"outputs": {"results": "'${outdir}'"}}'
fi