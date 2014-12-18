#!/bin/bash
# Provision the Oracle user to share the same keys as the vagrant user
# Requires privileged access

# This allows simple debugging by being able to ssh in as oracle
# This requires at least one, and possibly two changes to the Vagrantfile:

# First, add the oracle user
# config.ssh.username = "oracle"

# Secondly, forwrad X11 to allow for using a gui
# config.ssh.forward_x11 = true

# Configure oracle user for ssh access by copying in the insecure key
cp --recursive ~vagrant/.ssh ~oracle
chown --recursive oracle:oracle ~oracle
