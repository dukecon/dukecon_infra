$hiera_dukecon = hiera('dukecon')
$hiera_dukecon_apache = $hiera_dukecon['apache']
$hiera_dukecon_apache_ssl = $hiera_dukecon_apache['ssl']


class { 'apache':
  keepalive		=>	'On',
}

apache::vhost { 'dukecon.org':
  port		=>	'80',
  docroot	=>	'/var/www/html',
  allow_encoded_slashes	=>	'nodecode',
  proxy_preserve_host	=>	'true',
  proxy_pass		=>	[
    {	'path'		=>	'/javaland/',
	'url'		=>	'http://localhost:9080/javaland/',
    },
  ],
  redirect_source => ['/javaland',],
  redirect_dest   => ['/javaland/',],
}
apache::vhost { 'www.dukecon.org':
  port		=>	'80',
  docroot	=>	'/var/www/html',
}
apache::vhost { 'dev.dukecon.org':
  port			=>	'80',
  docroot		=>	'/var/www/html',
  allow_encoded_slashes	=>	'nodecode',
  proxy_preserve_host	=>	'true',
  proxy_pass		=>	[
    {	'path'		=>	'/jenkins',
	'url'		=>	'http://localhost:8080/jenkins',
	'keywords'	=>	['nocanon'],
    },
    {	'path'		=>	'/nexus/',
	'url'		=>	'http://localhost:8081/',
    },
    {	'path'		=>	'/latest/',
	'url'		=>	'http://localhost:9050/latest/',
    },
    {	'path'		=>	'/testdata/',
	'url'		=>	'http://localhost:9040/testdata/',
    },
    {	'path'		=>	'/testing/',
	'url'		=>	'http://localhost:9060/testing/',
    },
    {	'path'		=>	'/release/',
	'url'		=>	'http://localhost:9070/release/',
    },
    {	'path'		=>	'/ssltest/',
	'url'		=>	'http://localhost:9080/javaland/',
    },
  ],
  redirect_source => ['/nexus', '/latest', '/testdata', '/testing', '/release'],
  redirect_dest   => ['/nexus/', '/latest/', '/testdata/', '/testing/', '/release/'],
}

apache::vhost { 'keycloak.dukecon.org':
  port			=>	'80',
  docroot		=>	'/var/www/html',
  allow_encoded_slashes	=>	'nodecode',
  proxy_preserve_host	=>	'true',
  proxy_pass		=>	[
    {	'path'		=>	'/',
	'url'		=>	'http://localhost:9041/',
	'reverse_urls'	=>	'http://localhost:9041/',
    },
  ],
  # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
  headers => 'set P3P "CP=\"Potato\""'
}

if $hiera_dukecon_apache_ssl {
  # SSL - there can be only one!
  apache::vhost { 'ssl.dukecon.org':
    servername             =>  'dukecon.org',
    port                   =>  '443',
    ssl                    =>  true,
    ssl_cert               =>  '/etc/tls/server.pem',
    ssl_key                =>  '/etc/tls/key.pem',
    ssl_ca                 =>  '/etc/tls/startssl-chain.pem',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers =>  [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host    =>  'true',
    proxy_pass             =>  [
      { 'path'      =>  '/jenkins',
        'url'       =>  'http://localhost:8080/jenkins',
        'keywords'  =>  ['nocanon'],
      },
      { 'path'    =>  '/nexus/',
        'url'     =>  'http://localhost:8081/',
      },
      { 'path'          =>  '/auth/',
        'url'           =>  'http://localhost:9041/auth/',
        'reverse_urls'  =>  'http://localhost:9041/auth/',
      },
      { 'path'    =>  '/latest/',
        'url'     =>  'http://localhost:9050/latest/',
      },
      { 'path'    =>  '/testdata/',
        'url'     =>  'http://localhost:9040/testdata/',
      },
      { 'path'    =>  '/testing/',
        'url'     =>  'http://localhost:9060/testing/',
      },
      { 'path'    =>  '/release/',
        'url'     =>  'http://localhost:9070/release/',
      },
      { 'path'    =>  '/ssltest/',
        'url'     =>  'http://localhost:9050/latest/',
      },
    ],
    redirect_source        => ['/auth',  '/nexus',  '/latest',  '/testdata',  '/testing',  '/release'],
    redirect_dest          => ['/auth/', '/nexus/', '/latest/', '/testdata/', '/testing/', '/release/'],
  }
}
