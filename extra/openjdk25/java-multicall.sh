#!/usr/bin/bash

JDK_DIR="$(realpath "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/../)"
CMD=$(basename "$0")

LD_LIBRARY_PATH="$(realpath $JDK_DIR/lib):$LD_LIBRARY_PATH" "$JDK_DIR/bin/bin/$CMD" "$@"


