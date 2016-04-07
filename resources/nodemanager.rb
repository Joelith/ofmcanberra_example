#
# Cookbook Name:: fmw_domain
# Resource:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#

# Configure the nodemanager service on a RedHat family host
actions :configure

# Make create the default action
default_action :configure

# operating system user
attribute :os_user, kind_of: String, required: true