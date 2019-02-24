$hiera_docker_registry_mirror = lookup('docker.registry.mirror', String, 'deep', 'localhost:5000')

class { 'docker':
  # TODO: Enable this on "development" (i.e., "local" Vagrant machine)
  tcp_bind         => 'tcp://127.0.0.1:2375',
  socket_bind	   => 'unix:///var/run/docker.sock',
  # TODO: clean this up/ensure the mirror is only set in local Vagrant box
  extra_parameters => "--registry-mirror=http://$hiera_docker_registry_mirror --insecure-registry $hiera_docker_registry_mirror",
}
->
docker_network { ['inspectit', 'monitoring']:
  ensure           => 'present',
}

file { "/data":
  path             =>      "/data",
  ensure           =>      directory,
  mode             =>      '0755',
}
file { "/etc/docker-compose":
  ensure        => 'directory',
  mode          => '0755',
}

exec { '/bin/echo "This is a Vagrant Host"':
  onlyif           => '/bin/grep -q vagrant /etc/passwd',
}
->
user { 'vagrant':
  ensure           => present,
  groups           => ['docker'],
  require          => Class['docker'],
}
