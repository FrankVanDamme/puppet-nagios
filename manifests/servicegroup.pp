# Define nagios::servicegroup
#
#
define nagios::servicegroup (
  $members,
  $alias_name,
  $ensure        = 'present',
  $template      = 'nagios/servicegroup.erb',
  ) {

  include nagios::target

  case $::nagios_filemode {

    'concat': {
      if $ensure == 'present' {
        @@concat { "${nagios::target::customconfigdir}/servicesgroups/${name}.cfg":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          tag     => "nagios_check_${nagios::target::magic_tag}",
        }
        @@concat::fragment { "nagios-${name}":
          target  => "${nagios::target::customconfigdir}/servicesgroups/${name}.cfg",
          order   => 01,
          notify  => Service['nagios'],
          content => template( $template ),
          tag     => "nagios_check_${nagios::target::magic_tag}",
        }
      }
    }

    'pupmod-concat': {
      if $ensure == 'present' {
        @@concat_build { "nagios-${::servicename}":
          target => "${nagios::target::customconfigdir}/servicegroups/${name}.cfg",
          order  => ['*.tmp'],
        }
        @@concat_fragment { "nagios-${::servicename}+200_${name}.tmp":
          content => template( $template ),
        }
      }
    }

    default: {
      @@file { "${nagios::target::customconfigdir}/servicegroups/${name}.cfg":
        ensure  => $ensure,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['nagios'],
        content => template( $template ),
        tag     => "nagios_check_${nagios::target::magic_tag}",
      }
    }

  }

}

