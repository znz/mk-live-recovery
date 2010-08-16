#!/bin/sh
if [ "${LOCAL_TEST:+set}" != set ]; then
	exit
fi
cat <<EOF
menuentry '「Hello World」と言う (say "Hello World")' {
	hello
}
EOF
