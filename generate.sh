#!/bin/bash
set -e

if [[ -z "$FIX_ACCOUNT_ID" ]]; then
    echo "ERROR: FIX_ACCOUNT_ID environment variable is not set."
    exit 1
fi

temp_dir=$1
if [[ -z "$temp_dir" ]]; then
    echo "ERROR: Missing temp_dir argument."
    exit 1
fi
if [[ ! -d "$temp_dir" ]]; then
    echo "ERROR: $temp_dir is not a directory."
    exit 1
fi

fix_account_id=$FIX_ACCOUNT_ID
s3_bucket="fixpublic"
s3_prefix="aws"

template_file="fix-role.cf.template"
environments=("dev-eu" "eu" "us")
output_prefix="fix-role"

for env in ${environments[@]}; do
    output_file="$temp_dir/${output_prefix}-${env}.yaml"
    callback_url="https://app.${env}.fixcloud.io/api/cloud/callbacks/aws/cf"

    echo "Generating $output_file"
    sed -e "s/{{environment}}/${env}/g" \
        -e "s/{{fix_account_id}}/${fix_account_id}/g" \
        -e "s#{{callback_url}}#${callback_url}#g" \
        "$template_file" > "$output_file"
done
