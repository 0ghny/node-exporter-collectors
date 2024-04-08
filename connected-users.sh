#!/usr/bin/env bash
# @description Expose connected users info as metrics.
# users command – See the login names of the users currently on the system,
# in sorted order, space separated, on a single line. It reads all information from /var/run/utmp file.

collector_metric_prefix="node_users"
declare -a connected_users=($(users))

# @metric Total connected users
cat <<EOF
# HELP ${collector_metric_prefix}_total Total connected users.
# TYPE ${collector_metric_prefix}_total gauge
${collector_metric_prefix}_total ${#connected_users[@]}
EOF

# @metric Individual user names
cat <<EOF
# HELP ${collector_metric_prefix}_sessions_total Connected user and number of sessions.
# TYPE ${collector_metric_prefix}_sessions_total gauge
EOF
declare -a count_users=($((IFS=$'\n'; sort <<< "${connected_users[*]}") | uniq -c))
while read -r line; do
  count=$(echo $line | awk '{print $1}')
  user=$(echo $line | awk '{print $2}')
  echo "${collector_metric_prefix}_sessions_total{name=\"$user\"} $count"
done <<< "${count_users[@]}"
unset line
# Cleaning and getting global env settings back
unset connected_users
