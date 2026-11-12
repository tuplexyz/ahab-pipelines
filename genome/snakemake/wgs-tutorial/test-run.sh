#!/bin/bash
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP="$tmp"

ahab() {
    if [[ $2 == get ]]; then
        printf '%s\n' "$TEST_JOB"
    else
        printf '%s\n' "$6" > "$TEST_TMP/status"
        jq -e --arg outdir "$TEST_TMP/results with spaces" \
            '.outputs.results == $outdir' <<< "$8" >/dev/null
        jq -nc --arg id "$4" --arg status "$6" '{id: $id, status: $status}'
    fi
}
snakemake() {
    printf '%s\n' "$@" > "$TEST_TMP/args"
    return "${TEST_SNAKEMAKE_EXIT:-0}"
}
export -f ahab snakemake

export TEST_JOB
TEST_JOB=$(jq -nc --arg outdir "$tmp/results with spaces" \
    '{id: "job-1", inputs: {outdir: $outdir}}')
bash "$here/run.sh"
grep -Fx 'inputdir=/mnt/datalake/samples/sm_wgs/inputs' "$tmp/args"
grep -Fx "outdir=$tmp/results with spaces" "$tmp/args"
grep -Fx COMPLETE "$tmp/status"

export TEST_SNAKEMAKE_EXIT=42
if bash "$here/run.sh"; then
    echo "Expected Snakemake failure" >&2
    exit 1
else
    code=$?
    [[ $code == 42 ]]
fi
grep -Fx FAILED "$tmp/status"

TEST_JOB='{"message":"No pending jobs"}'
if bash "$here/run.sh"; then
    echo "Expected missing job to fail" >&2
    exit 1
fi
echo "WGS worker tests passed"