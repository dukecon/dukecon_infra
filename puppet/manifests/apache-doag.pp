class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

apache::vhost { 'programm.doag.org':
  servername            => 'programm.doag.org',
  ip                    => '85.214.231.45',
  port                  => '443',
  ssl                   => true,
  ssl_cert              => '/etc/tls/wildcard.doag.org.crt',
  ssl_key               => '/etc/tls/wildcard.doag.org.key',
  ssl_verify_client     => 'none',
  ssl_ca                => '/etc/tls/intermediate2021.crt',
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
    { 'path'     => '/conferences$',
      'url'      => 'http://localhost:9080/conferences',
    },
    { 'path'      =>  '^/(health|info|inspectit|login|oauth2|rest)(.+)',
      'url'       =>  'http://localhost:9080/$1$2',
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
  ssl_cert              => '/etc/tls/2019/javaland_2019.crt',
  ssl_key               => '/etc/tls/2019/javaland_2018.key',
  ssl_verify_client     => 'none',
  ssl_ca                => '/etc/tls/2019/javaland_intermediate.crt',
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
    { 'path'     => '/conferences$',
      'url'      => 'http://localhost:9090/conferences',
    },
    { 'path'      =>  '^/(health|info|inspectit|login|oauth2|rest)(.+)',
      'url'       =>  'http://localhost:9090/$1$2',
    },
    { 'path'      =>  '^/(.+)',
      'url'       =>  'http://localhost:9090/javaland/$1',
    },
  ],
  # For a new conference: Add a new redirect from "regexep" to "dest" with the new conference instance, e.g. '^/2017$' -> '/2017/'
  # For the current conference: replace the dest for the prevous year by the current year, e.g. 2018 -> 2019
  redirectmatch_regexp  => ['/auth',  '^/$',    '^/2016$', '^/2017$', '^/2018$', '^/2019$', '^/2020$', '^/2021$', '^/(\d+)', '^/(\d+)/'],
  redirectmatch_dest    => ['/auth/', '/2021/', '/2016/',  '/2017/',  '/2018/',  '/2019/',  '/2020/',  '/2021/',  '/2021/',  '/2021/'  ],
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
apache::vhost { 'nossl-programm.doag.org':
  servername            => 'programm.doag.org',
  ip                    => '85.214.231.45',
  port                  =>  '80',
  docroot               =>  '/var/www/html',
  allow_encoded_slashes =>  'nodecode',
  redirect_source       => ['/'],
  redirect_dest         => ['https://programm.doag.org/']
}

