$inspectit = 'dukecon/inspectit-cmr'

# docker::image { $inspectit: }

file { '/data/inspectit':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
}
file { '/data/inspectit/cmr':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
  require  => File['/data/inspectit']
}
file { '/data/inspectit/cmr/config':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
  require  => File['/data/inspectit/cmr']
}
file { '/data/inspectit/cmr/db':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
  require  => File['/data/inspectit/cmr']
}
file { '/data/inspectit/cmr/logs':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
  require  => File['/data/inspectit/cmr']
}
file { '/data/inspectit/cmr/storage':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
  require  => File['/data/inspectit/cmr']
}
docker::run { 'inspectit':
  image    => 'dukecon/inspectit-cmr',
  volumes  => [
    '/data/inspectit/cmr/config:/CMR/config',
    '/data/inspectit/cmr/db:/CMR/db',
    '/data/inspectit/cmr/logs:/CMR/logs',
    '/data/inspectit/cmr/storage:/CMR/storage'
  ],
  links    => ['influxdb:influxdb'],
  env      => ['INFLUXDB_PORT=8086'],
  net      => 'inspectit',
  ports    => [
    '127.0.0.1:8182:8182',
    '127.0.0.1:9070:9070',  ],
  require  => File['/data/inspectit/cmr/storage']
}
