# TODO: Only enable this on Vagrant machine
user { 'vagrant':
  ensure => present,
  groups => ['docker'],
  require => Class['docker'],
}
