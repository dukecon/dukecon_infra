class { 'docker':
  manage_kernel 	=> false,
  # TODO: Enable this on "development" (i.e., "local" Vagrant machine)
  # tcp_bind		=> 'tcp://0.0.0.0:2375',
  socket_bind		=> 'unix:///var/run/docker.sock',
  # TODO: clean this up/ensure the mirror is only set in local Vagrant box
  # extra_parameters	=> '--registry-mirror=http://10.211.55.6:5000 --insecure-registry 10.211.55.6:5000',
}

file_line { 'sudo docker restart for jenkins':
  path  	=> '/etc/sudoers',
  line => 'jenkins ALL = NOPASSWD: /etc/init.d/docker-dukecon-*',
  require => Package['docker']
}

user { 'jenkins':
  ensure => present,
  groups => ['docker'],
  require => Class['docker'],
}

# TODO: Only enable this on Vagrant machine
user { 'vagrant':
  ensure => present,
  groups => ['docker'],
  require => Class['docker'],
}
