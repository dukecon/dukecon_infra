$grafana = 'grafana/grafana'

docker::image { $grafana: }

file { '/data/grafana':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
}
->
docker::run { 'grafana':
  image    => $grafana,
  links    => 'influxdb',
  volumes  => ['/data/grafana:/var/lib/grafana'],
  ports    => ['127.0.0.1:3000:3000'],
}
