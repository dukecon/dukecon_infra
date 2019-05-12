class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

apache::vhost { 'nossl-apachecon.dukecon.org':
  servername            => 'apachecon.dukecon.org',
  ip                    => '88.99.79.88',
  port                  => '80',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  redirect_source       => ['/'],
  redirect_dest         => ['https://apachecon.dukecon.org/']
}

apache::vhost { 'ssl-apachecon.dukecon.org':
  servername            => 'apachecon.dukecon.org',
  ip                    => '88.99.79.88',
  port                  => '443',
  ssl                   => true,
  ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
  ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
  request_headers       => [ 'set X-Forwarded-Proto https' ],
  proxy_preserve_host   => 'true',
  proxy_pass_match      => [
    { 'path'      =>  '^/(.+)',
      'url'       =>  'http://localhost:9050/$1',
    },
  ],
  redirectmatch_regexp  => ['^/?$',      ],
  redirectmatch_dest    => ['/acna/2018/'],
  # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
  headers               => 'set P3P "CP=\"Potato\""'
}

apache::vhost { 'nossl-topdesk.dukecon.org':
  servername            => 'topdesk.dukecon.org',
  ip                    => '88.99.79.88',
  port                  => '80',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  redirect_source       => ['/'],
  redirect_dest         => ['https://topdesk.dukecon.org/']
}

apache::vhost { 'ssl-topdesk.dukecon.org':
  servername            => 'topdesk.dukecon.org',
  ip                    => '88.99.79.88',
  port                  => '443',
  ssl                   => true,
  ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
  ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
  docroot               => '/var/www/html',
  allow_encoded_slashes => 'nodecode',
  # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
  request_headers       => [ 'set X-Forwarded-Proto https' ],
  proxy_preserve_host   => 'true',
  proxy_pass_match      => [
    { 'path'      =>  '^/(.+)',
      'url'       =>  'http://localhost:9059/topdesk/$1',
    },
  ],
  redirectmatch_regexp  => ['^/?$',      ],
  redirectmatch_dest    => ['/2019/'],
  # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
  headers               => 'set P3P "CP=\"Potato\""'
}

