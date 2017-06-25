docker::image { 'influxdb': }

file { '/data/influxdb':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
}
->
docker::run { 'influxdb':
  image    => 'influxdb',
  volumes  => ['/data/influxdb:/var/lib/influxdb'],
  ports    => ['127.0.0.1:8086:8086'],
}
