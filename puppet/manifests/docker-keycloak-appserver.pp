$keycloak_image = "dukecon/dukecon-keycloak-postgres:1.1-SNAPSHOT"

# Make sure the passwords are available via Puppet Hiera, e.g., in /etc/puppetlabs/puppet/hieradata/common.yaml
#---
#keycloak:
#  postgres:
#   password: xxx
#   root_password: yyy

$keycloak_hiera_postgres_password = lookup('keycloak::postgres::password', String, 'unique', "test1234")

docker::image { $keycloak_image: }

docker::run { 'keycloak':
  image         => $keycloak_image,
  env           => ['POSTGRES_DATABASE=keycloak',
                    'POSTGRES_USER=keycloak',
                    "POSTGRES_PASSWORD=$keycloak_hiera_postgres_password",
                   ],
  links         => ['postgres-keycloak:postgres',],
  volumes       => ['/data/keycloak/configuration/keycloak-add-user.json:/opt/jboss/keycloak/standalone/configuration/keycloak-add-user.json'],
  ports         => ['127.0.0.1:9041:8080'],
  depends       => ['postgres-keycloak',],
}
