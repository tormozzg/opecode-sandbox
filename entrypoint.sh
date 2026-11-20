#!/usr/bin/env bash

source "$HOME/.sdkman/bin/sdkman-init.sh"

# Optional runtime override of the default Java version, e.g.
# `docker run -e JAVA_DEFAULT=17.0.12-zulu ...` (via OC_SAND_EXTRA_FLAGS).
if [ -n "${JAVA_DEFAULT:-}" ]; then
  sdk default java "$JAVA_DEFAULT" >/dev/null 2>&1 ||
    echo "warning: JAVA_DEFAULT=$JAVA_DEFAULT: sdk default java failed" >&2
fi

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ "$#" -eq 0 ]; then
  exec /bin/bash -l
else
  exec "$@"
fi
