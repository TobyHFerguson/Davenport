#!/bin/bash
# Install agent prereqs, and zip (which agentpull.sh needs)
# Packages which are required for agentpull.sh
EXTRA_PKGS=(zip unzip bc)
PKGS=(oracle-em-agent-12cR4-preinstall ${EXTRA_PKGS[*]})
rpm --quiet -q ${PKGS[*]} || yum  -q -y --disablerepo='*' --enablerepo='*ol6_addons,*ol6_latest' install ${PKGS[*]}


