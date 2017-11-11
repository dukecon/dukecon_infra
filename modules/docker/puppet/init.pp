class { 'docker':
  manage_kernel 	=> false,
  # TODO: Enable this on "development" (i.e., "local" Vagrant machine)
  tcp_bind		=> 'tcp://127.0.0.1:2375',
  socket_bind		=> 'unix:///var/run/docker.sock',
  # TODO: clean this up/ensure the mirror is only set in local Vagrant box
  # extra_parameters	=> '--registry-mirror=http://10.211.55.6:5000 --insecure-registry 10.211.55.6:5000',
}

file { "/data":
  path          =>      "/data",
  ensure        =>      directory,
  mode          =>      '0755',
}

exec { '/bin/echo "This is a Vagrant Host"':
  onlyif        => '/bin/grep -q vagrant /etc/passwd',
}
->
user { 'vagrant':
  ensure        => present,
  groups        => ['docker'],
  require       => Class['docker'],
}
