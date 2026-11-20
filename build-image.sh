#!/bin/bash
set -euo pipefail

image_name="$1"
# Space-separated sdkman JDK packages, e.g. "8.0.452-zulu 17.0.12-zulu 25.0.4+1.1-zulu".
# The LAST package runs the LSP servers and linters (jdtls needs Java 25).
jdk_packages="${2:-}"
# Optional: sdk default java version (defaults to the last package).
java_default="${3:-}"

# The in-image "opencode" user must match the host user only on Linux, where
# bind-mounted files keep their numeric owner. Docker Desktop on macOS
# virtualizes file ownership, so the IDs can stay at the Dockerfile defaults
# (1000:1000) -- and the macOS GID 20 ("staff") already exists in Debian as
# "dialout", which would break "groupadd".
if [[ "$(uname -s)" == "Linux" ]]; then
	user_id="$(id -u)"
	group_id="$(id -g)"
else
	user_id=1000
	group_id=1000
fi

build_args=(
	--progress=plain
	--build-arg USER_ID="$user_id"
	--build-arg GROUP_ID="$group_id"
)

if [[ -z "$jdk_packages" ]]; then
	docker build -t "$image_name" -f Dockerfile \
		"${build_args[@]}" .
else
	docker build -t oc-sandbox-base -f Dockerfile \
		"${build_args[@]}" .

	build_args+=(--build-arg JDK_PACKAGES="$jdk_packages")
	if [[ -n "$java_default" ]]; then
		build_args+=(--build-arg JAVA_DEFAULT="$java_default")
	fi

	docker build -t "$image_name" -f Dockerfile.jdk \
		"${build_args[@]}" \
		--build-arg BASE_IMAGE=oc-sandbox-base .
fi
