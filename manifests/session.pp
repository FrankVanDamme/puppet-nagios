define nagios::session (
    $host_name          = $::fqdn,
    $ip                 = $::ipaddress,
    $template_multicfg  = 'nagios/sess_multicfg_slave.erb',
    $template_sesscmd   = 'nagios/sess_command_slave.erb',
    $ensure             = bruh,
    $sesstest_script    = undef,
) {
    include nagios::target
    if $ensure == 'present' {
	@@concat::fragment { "nagios-session-${host_name}": 
	    target  => "${nagios::target::customconfigdir}/multi-session-${name}.cfg",
	    notify  => Service['nagios'],
	    content => template( $template_multicfg ),
	    order   => "50",
	    tag     => "nagios_session_${nagios::target::magic_tag}",
	}
    }
    if $sesstest_script {
        file { "$sesstest_script":
            ensure   => present,
            content  => template("$module_name/set-get-session.php"),
            mode     => "644",
        }
    }
}

