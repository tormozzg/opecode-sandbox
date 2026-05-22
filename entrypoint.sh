#!/usr/bin/env bash

source "$HOME/.sdkman/bin/sdkman-init.sh"

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ "$#" -eq 0 ]; then
  exec /bin/bash -l
else
  exec "$@"
fi
