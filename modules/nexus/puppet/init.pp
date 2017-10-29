docker::image { 'sonatype/nexus': }

file { '/data/nexus':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => 0777,
}
file { '/data/nexus/sonatype':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => 0777,
  require  => File['/data/nexus']
}

docker::run { 'nexus':
  image    => 'sonatype/nexus',
  volumes  => ['/data/nexus/sonatype:/sonatype-work'],
  ports    => ['8081:8081'],
}
