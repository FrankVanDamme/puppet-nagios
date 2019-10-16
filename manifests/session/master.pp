define nagios::session::master (
    $host_name          = $::fqdn,
    $ip                 = $::ipaddress,
    $template_multicfg  = 'nagios/sess_multicfg_master.erb',
    $template_sesscmd   = 'nagios/sess_command_master.erb',
    $ensure             = bruh,
    $sesstest_script    = undef,
) {
    include nagios::target
  notify { "in $name, magic_tag is ${nagios::target::magic_tag}; nagios_filemode is $nagios_filemode":}
    if $ensure == 'present' {
        # MULTI-CHECK config file
        $multi_cfgfile="${nagios::target::customconfigdir}/multi-session-${name}.cfg"
        @@concat { $multi_cfgfile: 
            owner   => 'root',
            group   => 'root', 
            mode    => '0644',
            tag     => "nagios_session_${nagios::target::magic_tag}",
        }
        @@concat::fragment { "nagios-session-master-${host_name}": 
            target  => $multi_cfgfile,
            notify  => Service['nagios'],
            content => template( $template_multicfg ),
            order   => "01",
            tag     => "nagios_session_${nagios::target::magic_tag}",
        }

        if $sesstest_script {
            file { "$sesstest_script":
                ensure   => present,
                content  => template("$module_name/set-get-session.php"),
                mode     => "644",
            }
        }

        # export a command so it gets realized on the Nagios server
        @@nagios::command { "session_$name":
            command_line => "/usr/lib/nagios/plugins/check_multi -f $multi_cfgfile",
            tag          => "nagios_session_${nagios::target::magic_tag}",
        }

        # Ain't much use without an actual service
        nagios::service { "session_$name":
            host_name     => "cluster-$name",
            check_command => "session_$name"
        }
        # ... so, we use a custom command for each cluster of web servers that
        # need to have consistent sessions, and have it hardcoded in the
        # service definition.
    }
}
