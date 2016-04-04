class nagios::fencing (
){
    $cluster_master=hiera("cluster_master")
    if ( $cluster_master == $hostname ){
	include nagios::fencing::master
    }
    #    -> exporteren van de host resource die de cluster voorstelt; member = naam van de master-node

    # define the service itself (fencing device which can kill the node we're
    # doing the puppet run on)
    nagios::service { "$hostname fencing":
	host_name     => $cluster,
	check_command => "check_nrpe_1arg!check_fence_$hostname",
	servicegroups => "critical",
    }
    nagios::plugin { "check_fence.sh": }
    # first, export a "fence resource check" for the fence device to this host...
    @@nrpe::config { "check_fence_$hostname.cfg": 
	content => "command[check_fence_$hostname]=sudo /usr/local/bin/check_fence.sh $hostname",
	tag     => "fence_cl_$cluster",
    }
    @@sudo::conf { "check_fence_$hostname": 
	priority => 20,
	content  => "nagios  ALL=(ALL) NOPASSWD: /usr/local/bin/check_fence.sh $hostname\n",
	tag     => "fence_cl_$cluster",
    }
    # ... then, realize them all.
    Nrpe::Config <<| tag == "fence_cl_$cluster" |>> 
    Sudo::Conf <<| tag == "fence_cl_$cluster" |>> 
}
