class nagios::hieras () {

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
