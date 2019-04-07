$dukecon_docker_instances = lookup ("dukecon.docker.instances",
  Array[Hash[String, String]],
  # Data,
  'deep', [
    # {
    #   'name'          => 'production',
    #   'server_port'   => '9080',
    #   'postgres_port' => '9082',
    # },
    {
      'name'            => 'latest',
      'label'           => 'latest',
      'server_port'     => '9050',
      'internal_port'   => '9051',
      'postgres_port'   => '9052',
      # Set the feedback port to '' to avoid setting up the feedback Docker
      'feedback_port'   => '', # '9053'
    }
  ])
$grafana_base_url = lookup ("grafana.base.url")
$keycloak_base_url = lookup ("keycloak.base.url")
$keycloak_client_secret = lookup ("keycloak.infrastructure.client.secret")

file { '/data/grafana':
  ensure   => directory,
  owner    => root,
  group    => root,
  mode     => '0755',
}
->
file { "/data/grafana/etc":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/grafana/etc/grafana.ini":
  ensure  => present,
  mode    => "0644",
  content => template("${module_basedir}/puppet/grafana.erb"),
}
->
file { "/data/grafana/data":
  ensure        =>      directory,
  mode          =>      '0777',
}
->
file { "/data/prometheus":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/prometheus/etc":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/prometheus/etc/prometheus.yml":
  ensure  => present,
  mode    => "0644",
  content => template("${module_basedir}/puppet/prometheus.erb"),
}
->
file { "/data/prometheus/data":
  ensure        =>      directory,
  mode          =>      '0777',
}
->
file { "/etc/docker-compose/monitoring":
  ensure        => 'directory',
  mode          => '0755',
}
->
file { "create docker-compose/monitoring":
  path    => "/etc/docker-compose/monitoring/docker-compose.yml",
  mode    => "0644",
  content => template("${module_basedir}/puppet/docker-compose.erb"),
}
->
docker_compose { "monitoring":
  compose_files => [
    "/etc/docker-compose/monitoring/docker-compose.yml"
  ],
  ensure        => present,
}
