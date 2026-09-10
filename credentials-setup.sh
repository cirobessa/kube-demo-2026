#!/usr/bin/env bash
#
# credentials-setup.sh
# Configure the local AWS CLI profile ("kube-demo") used by every module in this
# repo. Credentials are written to ~/.aws/ ONLY and must never be committed.
#
# Usage:
#   ./credentials-setup.sh                 # interactive prompt
#   AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... ./credentials-setup.sh   # non-interactive
#
set -euo pipefail

PROFILE="${AWS_PROFILE_NAME:-kube-demo}"
REGION="${AWS_REGION:-us-east-1}"

KEY="${AWS_ACCESS_KEY_ID:-}"
SECRET="${AWS_SECRET_ACCESS_KEY:-}"

if [[ -z "$KEY" ]]; then
  read -rp "AWS Access Key ID: " KEY
fi
if [[ -z "$SECRET" ]]; then
  read -rsp "AWS Secret Access Key: " SECRET
  echo
fi

if [[ -z "$KEY" || -z "$SECRET" ]]; then
  echo "error: access key and secret are both required" >&2
  exit 1
fi

mkdir -p "$HOME/.aws"
aws configure set aws_access_key_id     "$KEY"    --profile "$PROFILE"
aws configure set aws_secret_access_key "$SECRET" --profile "$PROFILE"
aws configure set region                "$REGION" --profile "$PROFILE"
aws configure set output                json      --profile "$PROFILE"

echo "Profile '$PROFILE' written to ~/.aws/. Verifying..."
aws sts get-caller-identity --profile "$PROFILE"
