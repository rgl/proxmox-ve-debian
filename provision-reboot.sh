#!/bin/bash
set -euxo pipefail

nohup bash -c "ps -eo pid,comm | awk '/sshd/{print \$1}' | xargs kill; sync; reboot"
