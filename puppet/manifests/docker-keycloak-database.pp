$postgres_version = "9.3"
$postgres_image = "postgres:$postgres_version"

package { "postgresql-client-$postgres_version": }

# Make sure the passwords are available via Puppet Hiera, e.g., in /etc/puppet/hieradata/common.yaml
#---
#keycloak:
#  postgres:
#    password: xxx
#	   root_password: yyy

# TODO: Check if there is a better way to set these variables, e.g., by "Automatic Parameter Lookup",
# cf. https://docs.puppetlabs.com/hiera/3.0/puppet.html#automatic-parameter-lookup
$keycloak_hiera = hiera('keycloak')
$keycloak_hiera_postgres = $keycloak_hiera['postgres']
$keycloak_hiera_postgres_password = $keycloak_hiera_postgres['password']
$keycloak_hiera_postgres_root_password = $keycloak_hiera_postgres['root_password']

file { "/data/postgresql":
  path          =>      "/data/postgresql",
  ensure        =>      directory,
  mode          =>      0755,
}

file { "/data/postgresql/keycloak":
  path          =>      "/data/postgresql/keycloak",
  ensure        =>      directory,
  mode          =>      0755,
  require       =>  File["/data/postgresql"],
}

file { "/data/postgresql/keycloak/data":
  path          =>      "/data/postgresql/keycloak/data",
  ensure        =>      directory,
  mode          =>      0700,
  require       =>  File["/data/postgresql/keycloak"],
}

docker::image { $postgres_image: }

docker::run { 'postgres-keycloak':
  image    => $postgres_image,
  env      => ['POSTGRES_DATABASE=keycloak',
    'POSTGRES_USER=keycloak',
    "POSTGRES_PASSWORD=$keycloak_hiera_postgres_password",
    "POSTGRES_ROOT_PASSWORD=$keycloak_hiera_postgres_root_password",
  ],
  ports    => ['127.0.0.1:9432:5432'],
  volumes  => [
    '/data/postgresql/keycloak/data:/var/lib/postgresql/data',
  ],
}
