#!/usr/bin/env bash
# @description Retrieve APT packages and expose info about pending, installed
# etc.
function package_manager() {
  if command -v apt &> /dev/null
  then
    echo "package_manager{name=\"apt\"} 1"
  fi
}

function package_installed() {
  apt list --installed 2>/dev/null | grep -i --invert-match "Listing..." \
  | awk -F '[/ ]' '{print "package_installed{type=\"apt\",name=\""$1"\",arch=\""$4"\",version=\""$3"\"} 1"}'
}

function package_installed_total() {
  echo "package_installed_total{type=\"apt\"} $(apt list --installed  2>/dev/null | grep -i --invert-match "Listing..." | uniq | wc -l)"
}

function package_upgrades_total() {
  echo "package_upgrades_total{type=\"apt\"} $(apt-get dist-upgrade --just-print | grep Inst | awk '{print $2}' | uniq | wc -l)"
}

function package_pending_remove_total() {
  echo "package_pending_remove_total{type=\"apt\"} $(apt-get --just-print autoremove | grep -i "^Remv" | awk '{print $2}' | uniq | wc -l)"
}

# @metric Package Manager installed
cat <<EOF
# HELP package_manager Package manager installed.
# TYPE package_manager gauge
$(package_manager)
EOF

# @metric Installed Packages
cat <<EOF
# HELP package_installed Package installed.
# TYPE package_installed gauge
$(package_installed)
EOF

# @metric Installed Packages Total
cat <<EOF
# HELP package_installed_total Total installed packages.
# TYPE package_installed_total gauge
$(package_installed_total)
EOF

# @metric Available Upgrades Total
cat <<EOF
# HELP package_upgrades_total Total available upgrades.
# TYPE package_upgrades_total gauge
$(package_upgrades_total)
EOF

# @metric Pending Remove Total
cat <<EOF
# HELP package_pending_remove_total Total pending removal.
# TYPE package_pending_remove_total gauge
$(package_pending_remove_total)
EOF
