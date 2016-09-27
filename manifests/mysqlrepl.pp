define nagios::mysqlrepl::slave (
    $check_ip,
    $server_id,
) {
    nrpe::config{ "check_mysql_repl_${name}.cfg":
	content => "command[check_mysql_repl_${name}]=check_mysql_all -K repl_all -H $check_ip --cnf /root/.my.cnf"
    }
}

define nagios::mysqlrepl::master (
    $server_id, 
) {
    nrpe::config{ "check_mysql_repl_${name}.cfg":
	content => "command[check_mysql_repl_${name}]=/usr/local/bin/mysql_masterhost",
    }
}

class nagios::mysqlrepl (
    $server_id=hiera(mysql_server_id)
) {
    $cluster_master=hiera("cluster_master")
    if ( $cluster_master == $hostname ){
	nagios::service { "mysql-masterhost-test":
	    host_name     => "cluster-$cluster",
	    check_command => "check_nrpe_1arg_logged!check_mysql_masterhost",
	}
    }
    file { '/usr/local/bin/check_mysql_all':
	owner => 'root',
	group => 'root',
	mode  => '0755',
	source => "puppet:///modules/$module_name/nagios-plugins/check-mysql/check_mysql_all"
    }
    # For every host in the cluster, a service is registered
    # in Nagios that monitors the status of the replication on that host.
    # Then, it is linked to the host in Nagios representing the cluster.
    # If the MySQL master is running on host A, then the NRPE daemon on that
    # host will perform the tasks of executing a check off the master status
    # locally and a check for the slave status to the other hosts.
    # The names of the checks, however, will always be called
    # "check_mysql_repl_$hostname".
    # This is why it doesn't make sense to link the service to a cluster node.
    nagios::service { "mysql-repl-$cluster-$::hostname":
	host_name     => "cluster-$cluster",
	check_command => "check_nrpe_1arg!check_mysql_repl_$::hostname",
    }
    # Every host exports a "slave" resource, which can be realized on all OTHER
    # hosts in your MySQL cluster. Basically it means "monitor the status of
    # the MySQL replication slave running on this host". 
    @@nagios::mysqlrepl::slave  { "$::hostname" :
	tag       => [ $::clientcert, $cluster ],
	server_id => $server_id,
	check_ip  => $::ipaddress,
    }
    # On the host doing the puppet run, install a nagios/nrpe command which 
    # checks the master status
    nagios::mysqlrepl::master  { "$::hostname" :
	tag       => [ $::clientcert, $cluster ],
	server_id => $server_id,
    }
    # Also install the "check the slave status of the other nodes" command,
    # excluding the one exported on the local host.
    Nagios::Mysqlrepl::Slave <<| title != "$::hostname" |>>
}
