#!/usr/bin/env bash

# @description Check for pending node reboot
collector_name="node_reboot"

reboot_required=0
if [[ -f '/run/reboot-required' ]]; then
  reboot_required=1
fi

# @metric
cat<<EOF
# HELP node_reboot_required Node reboot is required.
# TYPE node_reboot_required gauge
node_reboot_required ${reboot_required}
EOF

unset reboot_required
