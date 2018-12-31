$image = 'sonatype/nexus:2.14.11-01'

docker::image { $image: }

file { '/data/nexus':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0777',
}
file { '/data/nexus/sonatype':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0777',
  require  => File['/data/nexus']
}

docker::run { 'nexus':
  image    => $image,
  volumes  => ['/data/nexus/sonatype:/sonatype-work'],
  ports    => ['8081:8081'],
}
