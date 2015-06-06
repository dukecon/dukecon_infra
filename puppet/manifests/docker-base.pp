class { 'docker':
  manage_kernel 	=> false,
  # tcp_bind		=> 'tcp://0.0.0.0:2375',
  socket_bind		=> 'unix:///var/run/docker.sock',
}
