#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for RedHat family

def whyrun_supported?
  true
end

# Configure the nodemanager service on a RedHat family 7 host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    execute "chkconfig #{new_resource.name}" do
      command "chkconfig --add #{new_resource.name}"
      not_if "chkconfig | /bin/grep '#{new_resource.name}'"
    end

    #service new_resource.name do
    #  action :start
    #  supports status: true, restart: true, reload: true
    #end
  end
end