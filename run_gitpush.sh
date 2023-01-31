#!/bin/bash
spawn git_push.sh
expect "Username for 'https://github.com':"
send "pyvivid"
expect "Password for 'https://pyvivid@github.com':"
send "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"
