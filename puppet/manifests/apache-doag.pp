class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

apache::vhost { 'programm.doag.org':
  servername            => 'programm.doag.org',
  ip                    => '85.214.231.45',
  port                  => '443',
  ssl                   => true,
  ssl_cert              => '/etc/tls/doag2017.crt',
  ssl_key               => '/etc/tls/doag2014.key',
  ssl_verify_client     => 'none',
  ssl_ca                => '/etc/tls/intermediate.crt',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
  request_headers       => [ 'set X-Forwarded-Proto https' ],
  proxy_preserve_host   => 'true',
  proxy_pass_match      => [
    { 'path'          =>  '/auth/',
      'url'           =>  'http://localhost:9041',
      'reverse_urls'  =>  'http://localhost:9041',
    },
    { 'path'      =>  '^/(.+)',
      'url'       =>  'http://localhost:9080/$1',
    },
  ],
  redirect_source        => ['/auth',  ],
  redirect_dest          => ['/auth/', ],
  # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
  headers               => 'set P3P "CP=\"Potato\""'
}
apache::vhost { 'programm.javaland.eu':
  servername            => 'programm.javaland.eu',
  ip                    => '85.214.231.45',
  port                  => '443',
  ssl                   => true,
  ssl_cert              => '/etc/tls/javaland_2018.crt',
  ssl_key               => '/etc/tls/javaland_2018.key',
  ssl_verify_client     => 'none',
  ssl_ca                => '/etc/tls/javaland_inter.crt',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
  request_headers       => [ 'set X-Forwarded-Proto https' ],
  proxy_preserve_host   => 'true',
  proxy_pass_match      =>  [
    { 'path'          =>  '/auth/',
      'url'           =>  'http://localhost:9041',
      'reverse_urls'  =>  'http://localhost:9041',
    },
    { 'path'     => '/grafana/(.*)',
      'url'      => 'http://localhost:3000/$1',
    },
    # { 'path'     => '/conferences$',
    #   'url'      => 'http://localhost:9090/conferences',
    # },
    { 'path'      =>  '^/(conferences|health|info|inspectit|login|oauth2|rest)(.+)',
      'url'       =>  'http://localhost:9090/$1$2',
    },
    { 'path'      =>  '^/(.+)',
      'url'       =>  'http://localhost:9090/javaland/$1',
    },
  ],
  redirectmatch_regexp  => ['/auth',  '^/$',    '^/2016$', '^/2017$', '^/2018$', '^/(\d+)', '^/(\d+)/'],
  redirectmatch_dest    => ['/auth/', '/2018/', '/2016/',  '/2017/',  '/2018/',  '/2018/',  '/2018/'  ],
  # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
  headers               => 'set P3P "CP=\"Potato\""'
} 
apache::vhost { 'nossl-programm.javaland.eu':
  servername            => 'programm.javaland.eu',
  ip                    => '85.214.231.45',
  port                  =>  '80',
  docroot               =>  '/var/www/html',
  allow_encoded_slashes =>  'nodecode',
  redirect_source       => ['/'],
  redirect_dest         => ['https://programm.javaland.eu/']
}

