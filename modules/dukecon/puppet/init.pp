$docker_compose_version = lookup("docker.compose.version", String, 'deep', '1.18.0')

$dukecon_postgres_version = '9.5'
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
    'spring_profiles' => 'latest',
    'server_port'     => '9050',
    'internal_port'   => '9051',
    'postgres_port'   => '9052',
    # Set the feedback port to '' to avoid setting up the feedback Docker container
    'feedback_port'   => '', # '9053'
    # Set the edge_with_static port to '' to avoid setting up the edge-with-static Docker container
    'edge_with_static_port' => '', # '9059'
    'with_static_data'     => 'false',
  }
])

# For Backups
package { 'postgresql-client-common': }

class {'docker::compose':
  ensure        => present,
  version       => $docker_compose_version,
  install_path  =>  '/usr/bin',
}
->
file { "/data/dukecon":
  ensure        =>      directory,
  mode          =>      '0755',
}
# ->
$dukecon_docker_instances.each |$docker_instance| {
  $dukecon_instance_name = $docker_instance['name']
  $dukecon_instance_label = $docker_instance['label']
  $dukecon_instance_spring_profiles = $docker_instance['spring_profiles']
  $dukecon_instance_server_port = $docker_instance['server_port']
  $dukecon_instance_internal_port = $docker_instance['internal_port']
  $dukecon_instance_postgres_port = $docker_instance['postgres_port']
  $dukecon_instance_feedback_port = $docker_instance['feedback_port']
  $dukecon_instance_edge_with_static_port = $docker_instance['edge_with_static_port']
  $dukecon_instance_with_static_data = $docker_instance['with_static_data'] ? {
    /(true|false)/ => $docker_instance['with_static_data'],
    default        => "false"
  }
  file { "/data/dukecon/$dukecon_instance_name":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/postgresql":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/postgresql/data":
    ensure        =>      directory,
    mode          =>      '0700',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/postgresql/backup":
    ensure        =>      directory,
    mode          =>      '0700',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server/config":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  exec { "create /data/dukecon/$dukecon_instance_name/server/config/conferences.yml":
    unless   => "/usr/bin/test -r /data/dukecon/$dukecon_instance_name/server/config/conferences.yml",
    command  => "/bin/cat >/data/dukecon/$dukecon_instance_name/server/config/conferences.yml<<EOF
# This file must exist - so it is initially and intentionally created with empty contents
# Replace with a real conference configuration if possible!
EOF
",
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server/cache":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server/heapdumps":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server/logs":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/feedback":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/feedback/config":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/feedback/cache":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/feedback/heapdumps":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/feedback/logs":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/edge":
    ensure        => 'directory',
    mode          => '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/edge/logs":
    ensure        => 'directory',
    mode          => '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/edge/htdocs":
    ensure        => 'directory',
    mode          => '0755',
  }
  ->
  file { "create docker-compose directory dukecon-$dukecon_instance_name":
    path    => "/etc/docker-compose/dukecon-$dukecon_instance_name",
    ensure  => 'directory',
    mode    => "0755",
  }
  ->
  file { "create docker-compose file dukecon-$dukecon_instance_name di":
    path    => "/etc/docker-compose/dukecon-$dukecon_instance_name/docker-compose.yml",
    mode    => "0644",
    content => template("${module_basedir}/puppet/docker-compose.erb"),
  }
  ->
  docker_compose { "dukecon-$dukecon_instance_name":
    compose_files => [
      "/etc/docker-compose/dukecon-$dukecon_instance_name/docker-compose.yml"
    ],
    ensure        => present,
  }
  ->
  # TODO: Store password to ~/.pgpass
  file { "/etc/cron.daily/backup-dukecon-postgres-$dukecon_instance_name":
    owner          =>      'root',
    content        =>      "#!/bin/bash

export PGPASSWORD=dukecon
exec /usr/bin/pg_dump -h localhost -p $dukecon_instance_postgres_port -U dukecon -f /data/dukecon/$dukecon_instance_name/postgresql/backup/dukecon-$dukecon_instance_name.sql dukecon",
    mode           =>      '0700',
  }
}
