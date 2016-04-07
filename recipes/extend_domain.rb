middleware_home = '/u01/app/oracle/middleware'
tmp_dir = '/u01/data/software'
domain_dir = '/u01/data/domains'
app_dir = '/u01/app/oracle/middleware/user_projects/applications'
# Determine domain name (the cloud has a properties file for this)
properties = {}
::File::readlines("#{domain_dir}/jaas.properties").each do |line|
  properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
end
domain_home = properties["DOMAIN_HOME"]
domain_name = ::File::basename(properties["DOMAIN_HOME"])
domain_name_base = domain_name.gsub(/_domain/, '')

# Extend the domain to include BPM
wls_bpm_template        = "#{middleware_home}/soa/common/templates/wls/oracle.bpm_template.jar"
wls_em_template         = "#{middleware_home}/em/common/templates/wls/oracle.em_wls_template.jar"
wls_jrf_template        = "#{middleware_home}/oracle_common/common/templates/wls/oracle.jrf_template.jar"
wls_appl_core_template  = "#{middleware_home}/oracle_common/common/templates/wls/oracle.applcore.model.stub_template.jar"
wls_wsmpm_template      = "#{middleware_home}/oracle_common/common/templates/wls/oracle.wsmpm_template.jar"
wls_soa_template        = "#{middleware_home}/soa/common/templates/wls/oracle.soa_template.jar"
wls_bpm_template        = "#{middleware_home}/soa/common/templates/wls/oracle.bpm_template.jar"
wls_b2b_template        = "#{middleware_home}/soa/common/templates/wls/oracle.soa.b2b_template.jar"

cookbook_file tmp_dir + '/common.py' do
	source 	'common.py'
	action 	:create
	mode 		0755
	owner 	'oracle'
	group 	'oracle'
end

template tmp_dir + '/soa_suite.py' do
  source 'soa_suite.py'
  owner 'oracle'
  group 'oracle'
  variables(
    weblogic_home_dir:              "#{middleware_home}/wlserver",
    version:												'12.2.1',
    java_home_dir:                   '/u01/jdk',
    domain_dir:                     domain_home,
    domain_name:                    domain_name_base,
    app_dir:                        app_dir + '/' + domain_name,
    adminserver_name:               domain_name_base + '_adminserver',
    adminserver_listen_address:     "#{node['hostname']}.compute-#{node['oracle']['identity_domain']}.oraclecloud.internal",
    nodemanager_port:               5556,
    tmp_dir:                        tmp_dir,
    wls_em_template:                wls_em_template,
    wls_jrf_template:               wls_jrf_template,
    wls_appl_core_template:         wls_appl_core_template,
    wls_wsmpm_template:             wls_wsmpm_template,
    wls_soa_template:               wls_soa_template,
    wls_bpm_template:               wls_bpm_template,
    wls_b2b_template:               wls_b2b_template,
    bpm_enabled:                    true,
    soa_server_startup_arguments:   '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m',
    repository_database_url:        "jdbc:oracle:thin:@#{node['oracle']['db_service_name']}:1521/PDB1.#{node['oracle']['identity_domain']}.oraclecloud.internal",
    repository_prefix:              'DEVBPM122',
    machine_name:                   domain_name_base + '_machine_1',
    server_1_name:                  domain_name_base + '_server_1'
  )
end

template '/etc/init.d/nodemanager' do
  source 'nodemanager'
  mode 0755
  variables(platform_family:             node['platform_family'],
            nodemanager_lock_file:       "#{domain_home}/nodemanager/nodemanager.log.lck",
            nodemanager_bin_path:        "#{domain_home}/bin",
            nodemanager_check:           domain_home,
            os_user:                     'oracle')
end

ofmcanberra_example_nodemanager 'nodemanager' do
  os_user       'oracle'
end

unless ::File.exist?("#{domain_home}/config/config.xml") == true and
		::File.readlines("#{domain_home}/config/config.xml").grep(/soa-infra/).size > 0

 	# Stop the Node Manager
	service 'nodemanager' do
		action :stop
	end
	if DomainHelper.listening?('netstat -an | grep LISTEN', 8001, 3) then
	  execute 'Stop Managed Server' do
	  	user 'oracle'
	  	group 'oracle'
	  	command "#{domain_home}/bin/stopManagedWebLogic.sh #{domain_name_base }_server_1 #{node['hostname']}:7001 weblogic #{node['oracle']['weblogic_password']}"
	  end
	end
	if DomainHelper.listening?('netstat -an | grep LISTEN', 7001, 3) then
	  execute 'Stop Admin Server' do
	  	user 'oracle'
	  	group 'oracle'
	  	command "#{domain_home}/bin/stopManagedWebLogic.sh #{domain_name_base }_adminserver #{node['hostname']}:7001 weblogic #{node['oracle']['weblogic_password']}"
	  end
	end
 
	ofmcanberra_example_wlst "WLST add soa_suite domain extension" do
		version							"12.2.1"
		script_file         "#{tmp_dir}/soa_suite.py"
		middleware_home_dir middleware_home
		weblogic_home_dir   "#{middleware_home}/wlserver"
		java_home_dir       '/u01/jdk'
		tmp_dir             tmp_dir
		os_user             'oracle'
		repository_password node['oracle']['dba_password']
		weblogic_password		node['oracle']['weblogic_password']
	end

end


# Start the domain back up

# Start Node Manager
service 'nodemanager' do
	action :start
end
