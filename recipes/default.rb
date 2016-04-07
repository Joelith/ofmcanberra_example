#
# Cookbook Name:: ofmcanberra_example
# Recipe:: default
#
# Copyright 2016, Oracle Corporation
#
# All rights reserved - Do Not Redistribute
#

directory '/u01/data/software' do
  owner 'oracle'
  group 'oracle'
  mode 0755
  action :create
end

middleware_home = '/u01/app/oracle/middleware'
tmp_dir = '/u01/data/software'
domain_dir = '/u01/data/domains'
app_dir = '/u01/app/oracle/middleware/user_projects/applications'

# Install BPM
unless ::File.exist?("#{middleware_home}/soa/bin")
  directory "#{tmp_dir}/soa" do
    owner 'oracle'
    group 'oracle'
    mode 0755
    action :create
  end
  # Get the install files
  remote_file "#{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_1of2.zip" do
    source 'ftp://10.196.110.162/1221BPM/fmw_12.2.1.0.0_bpmqs_Disk1_1of2.zip'
    owner 'oracle'
    group 'oracle'
    backup false
    action :create
  end
  # Unzip
  execute 'Unpack BPM Disk 1' do
    user 'oracle'
    group 'oracle'
    command "unzip #{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_1of2.zip -d #{tmp_dir}/soa"
  end
   # Remove zip files to ensure we have space
  file "#{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_1of2.zip" do
    backup false
    action :delete
  end
  remote_file "#{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_2of2.zip" do
    source 'ftp://10.196.110.162/1221BPM/fmw_12.2.1.0.0_bpmqs_Disk1_2of2.zip'
    owner 'oracle'
    group 'oracle'
    backup false
    action :create
  end
  # Unzip Disk 2
  execute 'Unpack BPM Disk 2' do
    user 'oracle'
    group 'oracle'
    command "unzip #{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_2of2.zip -d #{tmp_dir}/soa"
  end
  file "#{tmp_dir}/soa/fmw_12.2.1.0.0_bpmqs_Disk1_2of2.zip" do
    backup false
    action :delete
  end
  
  template "#{tmp_dir}/soa/soa_fmw_12c.rsp" do
    source 'fmw_12c.rsp'
    mode 0755
    owner 'oracle'
    group 'oracle'
    variables(middleware_home_dir: middleware_home,
              oracle_home: "#{middleware_home}/soa/bin",
              install_type: 'BPM',
              option_array: [])
  end

  # Now install
  execute 'Install BPM' do
    command "/u01/jdk/bin/java -Xmx1024m -Djava.io.tmpdir=#{tmp_dir} -jar #{tmp_dir}/soa/fmw_12.2.1.0.0_bpm_quickstart.jar -silent -responseFile #{tmp_dir}/soa/soa_fmw_12c.rsp -invPtrLoc #{middleware_home}/oraInst.loc -jreLoc /u01/jdk"
    user 'oracle'
    group 'oracle'
    cwd tmp_dir
  end

  # Clean up
  directory "#{tmp_dir}/soa" do
    recursive true
    action :delete
  end
end

# Configure RCU
cookbook_file "#{tmp_dir}/checkrcu.py" do
  source 'checkrcu.py'
  action :create
  owner 'oracle'
  group 'oracle'
  mode 0775
end

ofmcanberra_example_repository 'RCU' do
  tmp_dir tmp_dir
  middleware_home middleware_home
  db_service_name node['oracle']['db_service_name']
  dba_name node['oracle']['dba_name']
  dba_password node['oracle']['dba_password']
  identity_domain node['oracle']['identity_domain']
  action :create
end

include_recipe 'ofmcanberra_example::extend_domain'

