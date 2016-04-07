require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

action :execute do
  Chef::Log.info("#{@new_resource} execute the WLST script")
  converge_by("Create resource #{ @new_resource }") do
    DomainHelper.wlst_execute(@new_resource.version, @new_resource.os_user, @new_resource.script_file, @new_resource.weblogic_home_dir, @new_resource.weblogic_password, @new_resource.repository_password)
    new_resource.updated_by_last_action(true)
  end
end