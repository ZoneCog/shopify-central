#!/usr/bin/env bash

set -eo pipefail

version=$(buildkite-agent meta-data get "agent-version")
build=$(buildkite-agent meta-data get "agent-version-build")

if [[ "$CODENAME" == "experimental" ]]; then
  version="$version.$build"
fi

echo "--- :package: Downloading built binaries"

rm -rf pkg/*
buildkite-agent artifact download --step '📦' "pkg/buildkite-agent-*" .
cd pkg

echo "--- :s3: Publishing $version to download.buildkite.com"

s3_base_url="s3://download.buildkite.com/agent/$CODENAME"

for binary in *; do
  binary_s3_url="$s3_base_url/$version/$binary"

  echo "Publishing $binary to $binary_s3_url"
  aws s3 --region "us-east-1" cp --acl "public-read" "$binary" "$binary_s3_url"

  echo "Calculating SHA256"
  sha256sum "$binary" | awk '{print $1}' > "$binary.sha256"

  echo "Publishing $binary.sha256 to $binary_s3_url.sha256"
  aws s3 cp --region "us-east-1" --acl "public-read" --content-type "text/plain" "$binary.sha256" "$binary_s3_url.sha256"
done

echo "--- :s3: Copying /$version to /latest"

latest_version=$(aws s3 ls --region "us-east-1" "$s3_base_url/" | grep PRE | awk '{print $2}' | awk -F '/' '{print $1}' | ruby ../scripts/utils/latest_version.rb)
latest_version_s3_url="$s3_base_url/$latest_version/"
latest_s3_url="$s3_base_url/latest/"

echo "Copying $latest_version_s3_url to $latest_s3_url"

aws s3 cp --region "us-east-1" --acl "public-read" --recursive "$latest_version_s3_url" "$latest_s3_url"

echo "--- :llama::sparkles::llama: All done!"
