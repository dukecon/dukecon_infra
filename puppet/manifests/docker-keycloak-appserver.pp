$keycloak_image = "ascheman/keycloak-postgres-https:1.8.0.JavaLand"

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

docker::image { $keycloak_image: }

docker::run { 'keycloak':
  image		=> $keycloak_image,
  env			=> ['POSTGRES_DATABASE=keycloak',
		        	'POSTGRES_USER=keycloak',
							"POSTGRES_PASSWORD=$keycloak_hiera_postgres_password",
						 ],
  links   => ['postgres-keycloak:postgres',],
  ports		=> ['127.0.0.1:9041:8080'],
  depends	=> ['postgres-keycloak',],
}
