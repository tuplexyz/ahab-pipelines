#!/bin/bash

set -o pipefail

echo "Grabbing a rnaseq job via the ahab CLI..."
if ! job_json=$(ahab job get --job_type rnaseq); then
    echo "Failed to retrieve a job." >&2
    exit 1
fi
if ! id=$(jq -er '.id | select(type == "string" and length > 0)' <<< "$job_json"); then
    echo "Job response has no valid id." >&2
    exit 1
fi

update_status() {
    local status="$1" body response
    body=$(jq -nc --arg outdir "${outdir:-}" '{outputs: {results: $outdir}}') || return 1
    if ! response=$(ahab job update --id "$id" --status "$status" --body "$body"); then
        echo "Failed to update job status to $status." >&2
        return 1
    fi
    echo "$response"
    jq -e --arg id "$id" --arg status "$status" \
        '.id == $id and .status == $status' <<< "$response" >/dev/null
}

## Input Parameters
if ! transcriptome=$(jq -er '.inputs.transcriptome | select(type == "string" and length > 0)' <<< "$job_json") ||
   ! reads=$(jq -er '.inputs.reads | select(type == "string" and length > 0)' <<< "$job_json") ||
   ! outdir=$(jq -er '.inputs.outdir | select(type == "string" and length > 0)' <<< "$job_json"); then
    echo "Job response is missing required RNA-seq inputs." >&2
    update_status FAILED || true
    exit 1
fi
multiqc=$PWD/multiqc

## Make output directory
echo "Making output directory..."
if ! mkdir -p -- "$outdir"; then
    echo "Failed to create output directory." >&2
    update_status FAILED || true
    exit 1
fi

echo "Running Nextflow pipeline..."
if NXF_SYNTAX_PARSER=v1 nextflow run . \
    --transcriptome "$transcriptome" --reads "$reads" \
    --outdir "$outdir" --multiqc "$multiqc"; then
    echo "Nextflow pipeline completed. Updating ahab job status..."
    update_status COMPLETE || exit 1
else
    pipeline_status=$?
    echo "Nextflow pipeline failed. Updating ahab job status..."
    update_status FAILED || true
    exit "$pipeline_status"
fi


