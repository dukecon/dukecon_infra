# Set params/versions here
$instance = "keycloak"  # default: keycloak
$localpgport = 9432        # default: 9432
$localkcport = 9041         # default: 9041

$postgres_version = "9.6"
$postgres_client_version = "10" # Ubuntu 18.04 LTS!
$keycloak_version = "1.2-SNAPSHOT"
# Computed
$rootdir = "/data/$instance"
$postgres_image = "postgres:$postgres_version"
$keycloak_image = "dukecon/dukecon-keycloak-postgres:$keycloak_version"

# Prepare installations of packages and Docker images
package { 'postgresql-client-common': }
package { "postgresql-client-$postgres_client_version": }
docker::image { $postgres_image: }
docker::image { $keycloak_image: }

# Make sure the passwords are available via Puppet Hiera, e.g., in /etc/puppetlabs/puppet/hieradata/common.yaml
#---
#keycloak:
#  postgres:
#    password: xxx
#	   root_password: yyy

$keycloak_hiera_postgres_password = lookup('keycloak.postgres.password', String, 'deep', "test1234")
$keycloak_hiera_postgres_root_password = lookup('keycloak.postgres.password', String, 'deep', "test1234")

file { "$rootdir":
  path          =>      "$rootdir",
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "$rootdir/postgresql":
  path          =>      "$rootdir/postgresql",
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "$rootdir/postgresql/data":
  path          =>      "$rootdir/postgresql/data",
  ensure        =>      directory,
  mode          =>      '0700',
}
->
file { "$rootdir/backup":
  path          =>      "$rootdir/backup",
  ensure        =>      directory,
  mode          =>      '0700',
}
->
file { "$rootdir/server":
  path          =>      "$rootdir/server",
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "$rootdir/server/log":
  path          =>      "$rootdir/server/log",
  ensure        =>      directory,
  mode          =>      '0777',
}

docker::run { "postgres-$instance":
  image    => $postgres_image,
  env      => ["POSTGRES_DATABASE=keycloak",
    'POSTGRES_USER=keycloak',
    "POSTGRES_PASSWORD=$keycloak_hiera_postgres_password",
    "POSTGRES_ROOT_PASSWORD=$keycloak_hiera_postgres_root_password",
  ],
  ports    => ["127.0.0.1:$localpgport:5432"],
  volumes  => [
    "$rootdir/postgresql/data:/var/lib/postgresql/data",
  ],
}

# TODO: Store password to ~/.pgpass
file { "/etc/cron.daily/backup-postgres-$instance":
  path           =>      "/etc/cron.daily/backup-postgres-$instance",
  owner          =>      'root',
  content        =>      "#!/bin/bash

exec docker exec postgres-$instance pg_dump -U keycloak > $rootdir/backup/keycloak.sql",
  mode           =>      '0700',
  require        =>      [
    Service["docker-postgres-$instance"],
    File["$rootdir/backup"],
  ],
}

docker::run { "$instance":
  image         => $keycloak_image,
  env           => ["DB_DATABASE=keycloak",
    'DB_USER=keycloak',
    "DB_PASSWORD=$keycloak_hiera_postgres_password",
    "DB_PORT=5432", # Workaround for failure in PG 9.6 Docker image
    "PROXY_ADDRESS_FORWARDING=true", # cf. https://stackoverflow.com/questions/53564499/keycloak-invalid-parameter-redirect-uri-behind-a-reverse-proxy
  ],
  links         => ["postgres-$instance:postgres",],
  volumes       => ["$rootdir/server/log:/opt/jboss/keycloak/standalone/log"],
  ports         => ["127.0.0.1:$localkcport:8080"],
  depends       => ["postgres-$instance",],
}
