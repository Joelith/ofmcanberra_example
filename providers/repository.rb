require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

action :create do

	# Check if RCU needs to be run
	# Note: This assumes port 1521 and PDB1 (should add to config)
	rcu_exists = false
	rcu_prefix = 'DEVBPM122'
	shell_out!("su - oracle -c '#{new_resource.middleware_home}/oracle_common/common/bin/wlst.sh #{new_resource.tmp_dir}/checkrcu.py jdbc:oracle:thin:@#{new_resource.db_service_name}:1521/PDB1.#{new_resource.identity_domain}.oraclecloud.internal #{new_resource.dba_password} #{rcu_prefix} #{new_resource.dba_name}'").stdout.each_line do |line|
	  unless line.nil?
	    if line.include? 'found'
	    	puts "\nRCU Already configured\n"
	      rcu_exists = true
	    end
	    fail if line.include? 'IO Error'
	  end
	end

	unless rcu_exists
		component_array = ['MDS', 'IAU', 'IAU_APPEND', 'IAU_VIEWER', 'OPSS', 'WLS', 'STB', 'UCSUMS', 'ESS', 'SOAINFRA']
	
		components_string = ' -component ' + component_array.join(' -component ')

 		script = 'rcu_input'
    content = "#{new_resource.dba_password}\n"
    for i in 0..component_array.length
      content += "#{new_resource.dba_password}\n"
    end

		tmp_file = Tempfile.new([script, '.py'])
		tmp_file.write(content)
		tmp_file.close
		FileUtils.chown('oracle', 'oracle', tmp_file.path)
 		execute "Create #{rcu_prefix}" do
	    command "#{new_resource.middleware_home}/oracle_common/bin/rcu -silent -createRepository -databaseType ORACLE -connectString #{new_resource.db_service_name}:1521/PDB1.#{new_resource.identity_domain}.oraclecloud.internal -dbUser #{new_resource.dba_name} -dbRole SYSDBA  -schemaPrefix #{rcu_prefix} #{components_string} -f < #{tmp_file.path}"
	    user 'oracle'
	    group 'oracle'
	    cwd new_resource.tmp_dir
	    environment('JAVA_HOME' => '/u01/jdk')
	  end

    new_resource.updated_by_last_action(true)
 	end
end