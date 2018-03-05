$cassandra = 'cassandra'

docker::image { $cassandra: }

file { '/data/cassandra':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
}
->
docker::run { 'cassandra':
  image    => $cassandra,
  volumes  => ['/data/cassandra:/var/lib/cassandra'],
  net      => 'inspectit',
  ports    => [
    '127.0.0.1:9042:9042',
  ],
}
