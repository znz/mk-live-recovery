#!/bin/bash
if [ x"$1" = x"data" ]; then
    cat <<EOF
+ /home/
+ /home/**
- *
EOF
fi
