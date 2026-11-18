#!/bin/bash
set -euo pipefail

image_name="$1"
jdk_package="${2:-}"

build_args=(
	--progress=plain
	--build-arg USER_ID="$(id -u)"
	--build-arg GROUP_ID="$(id -g)"
)

if [[ -z "$jdk_package" ]]; then
	docker build -t "$image_name" -f Dockerfile \
		"${build_args[@]}" .
else
	docker build -t oc-sandbox-base -f Dockerfile \
		"${build_args[@]}" .

	docker build -t "$image_name" -f Dockerfile.jdk \
		"${build_args[@]}" \
		--build-arg BASE_IMAGE=oc-sandbox-base \
		--build-arg JDK_PACKAGE="$jdk_package" .
fi
