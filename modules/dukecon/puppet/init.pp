$docker_compose_version = lookup("docker::compose::version", String, 'unique', '1.18.0')

$dukecon_postgres_version = '9.5'
$dukecon_docker_instances = lookup ("dukecon::docker::instances",
  Array[Hash[String, String]],
  # Data,
  'deep', [
  # {
  #   'name'          => 'production',
  #   'server_port'   => '9080',
  #   'postgres_port' => '9082',
  # },
  {
    'name'            => 'testing',
    'server_port'     => '9060',
    'postgres_port'   => '9062',
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
->
file { "/etc/docker-compose":
  ensure        => 'directory',
  mode          => '0755',
}
# ->
$dukecon_docker_instances.each |$docker_instance| {
  $dukecon_instance_name = $docker_instance['name']
  $dukecon_instance_server_port = $docker_instance['server_port']
  $dukecon_instance_postgres_port = $docker_instance['postgres_port']
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
  file { "/data/dukecon/$dukecon_instance_name/server/cache":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/data/dukecon/$dukecon_instance_name/server/logs":
    ensure        =>      directory,
    mode          =>      '0755',
  }
  ->
  file { "/etc/docker-compose/dukecon-$dukecon_instance_name":
    ensure        => 'directory',
    mode          => '0755',
    require       => File['/etc/docker-compose']
  }
  ->
  file { "create docker-compose/dukecon-$dukecon_instance_name":
    path    => "/etc/docker-compose/dukecon-$dukecon_instance_name/docker-compose.yml",
    mode    => "0644",
    content => template("${module_basedir}/puppet/docker-compose.erb"),
  }
  ->
  docker_compose { "/etc/docker-compose/dukecon-$dukecon_instance_name/docker-compose.yml":
    ensure => present,
  }
}