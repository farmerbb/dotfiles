#!/bin/bash
"""true"

[[ -z $(which kscript) ]] && install-kscript
kscript -s $0 "$@"
exit $?

"""

println("Hello from kscript!")
