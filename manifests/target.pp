#
# Class: nagios::target
#
# Basic host target class
# Include it on nodes to be monitored by nagios
#
# Usage:
# include nagios::target
#
class nagios::target (
  Hash $commands                = {},
  Hash $contacts                = {},
  Hash $contactgroups           = {},
  Hash $plugins                 = {},
  Hash $hosts                   = {},
  Hash $hostgroups              = {},
  Hash $services                = {},
  Hash $servicegroups           = {},
  String $config_dir            = params_lookup('config_dir'),
) inherits nagios::params {
  # # #
  # Here is defined where on nagios server check files are saved
  # This MUST be the same of $::nagios::customconfigdir
  # HINT: Do not mess with default path names...

  $customconfigdir = "${config_dir}/auto.d"
  $magic_tag = get_magicvar($::nagios_grouplogic)

  if !defined(Nagios::Host[$::fqdn]) {
    $host_template = $::nagios_host_template ? {
      ''      => 'nagios/host.erb',
      default => $::nagios_host_template,
    }
    nagios::host { $::fqdn:
      use      => 'generic-host',
      template => $host_template,
    }
  }

  $baseservices_template = $::nagios_baseservices_template ? {
    ''      => 'nagios/baseservices.erb',
    default => $::nagios_baseservices_template,
  }
  if !defined(Nagios::Baseservices[$::fqdn]) {
  nagios::baseservices { $::fqdn:
    use      => 'generic-service',
    template => $baseservices_template,
  }
  }

  include nagios::plugins

# TODO: Automatic hostgroup management is broken. We'll review it later
#  nagios::hostgroup { "${nagios::params::hostgroups}-$fqdn":
#    hostgroup => "${nagios::params::hostgroups}",
#  }

$pluginss=getvar("plugins")
notify {"pluginss: $pluginss":}
  $restypes = [ 
    'command', 
    'contact', 
    'contactgroup', 
    'host',
    'hostgroup',
    'plugin',
    'service',
    'servicegroup',  
  ]

  $restypes.each | $restype | {

    # a (hash) parameter listing the resources is good,
    # but a hiera lookup for the same is better 

    $result = hiera_hash("${module_name}::${restype}s", undef)

    # we want the value of the variable called, for example, $servicegroups
    $typeval = getvar("${restype}s")

    $final = $result ? {
      undef   => $typeval,
      ''      => $typeval,
      default => $result,
    }

    validate_hash($final)

    # for each hash element of $final, create a resource with 
    # the name = key,
    # parameters = elements,
    # and type is $restype

    $fulltype = "${module_name}::${restype}"
    $final.each | $name, $args | {
      Resource[$fulltype] { $name:
	  * => $args
       }
    }
  }
}
