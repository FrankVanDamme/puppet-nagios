class nagios::fencing::master (
) {
    $cluster=hiera("cluster")
    $cluster_fullname=hiera("clustername",$cluster)
    $cluster_ip=hiera("cluster_ip")

    nagios::host { "cluster-$cluster":
	short_alias => $cluster_fullname,
	ip          => $cluster_ip,
    }
}
