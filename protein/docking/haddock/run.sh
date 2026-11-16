#!/bin/bash

set -o pipefail

echo "Grabbing a haddock job via the ahab CLI..."
if ! job_json=$(ahab job get --job_type haddock); then
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
if ! workdir=$(jq -er '.inputs.workdir | select(type == "string" and length > 0)' <<< "$job_json") ||
   ! cfg_file=$(jq -er '.inputs.cfg_file | select(type == "string" and length > 0)' <<< "$job_json"); then
    echo "Job response is missing required haddock inputs." >&2
    update_status FAILED || true
    exit 1
fi


## Make output directory
echo "Making output directory..."
if ! mkdir -p -- "$outdir"; then
    echo "Failed to create output directory." >&2
    update_status FAILED || true
    exit 1
fi

echo "Running HADDOCK3 pipeline..."
if haddock3 "$cfg_file"; then
    echo "HADDOCK3 pipeline completed. Updating ahab job status..."
    update_status COMPLETE || exit 1
else
    pipeline_status=$?
    echo "HADDOCK3 pipeline failed. Updating ahab job status..."
    update_status FAILED || true
    exit "$pipeline_status"
fi


