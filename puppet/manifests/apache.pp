$hiera_dukecon = hiera('dukecon')
$hiera_dukecon_apache = $hiera_dukecon['apache']
$hiera_dukecon_apache_ssl = $hiera_dukecon_apache['ssl']


class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

if $hiera_dukecon_apache_ssl {
  apache::vhost { 'dukecon.org':
    ip                     => '85.214.26.208',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    redirect_status        =>  'permanent',
    redirect_source        => [
      '/javaland',
      '/javaland/',
      '/JavaLand',
      '/jfs',
      '/jfs/',
    ],
    redirect_dest          => [
      'https://dukecon.org/javaland',
      'https://dukecon.org/javaland/',
      'https://dukecon.org/javaland',
      'https://dukecon.org/jfs',
      'https://dukecon.org/jfs/',
    ],
  }

  apache::vhost { 'www.dukecon.org':
    ip                     => '85.214.26.208',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
  }

  apache::vhost { 'keycloak.dukecon.org':
    ip                     => '85.214.26.208',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    redirect_status        =>  'permanent',
    redirect_source        =>  '/',
    redirect_dest          =>  'https://keycloak.dukecon.org/',
  }

  apache::vhost { 'dev.dukecon.org':
    ip                     => '85.214.26.208',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    proxy_preserve_host    =>  'true',
    proxy_pass             =>  [
      { 'path'    =>  '/nexus/',
        'url'     =>  'http://localhost:8081/',
      },
    ],
    redirect_source        => [
      '/nexus',

      '/jenkins',
      '/latest',
      '/testdata',
      '/testing',
      '/release',
      '/javaland',
      '/jfslatest',

      '/jenkins/',
      '/latest/',
      '/testdata/',
      '/testing/',
      '/release/',
      '/javaland/',
      '/jfslatest/',
    ],
    redirect_dest          => [
      '/nexus/',

      'https://dev.dukecon.org/jenkins',
      'https://dev.dukecon.org/latest',
      'https://dev.dukecon.org/testdata',
      'https://dev.dukecon.org/testing',
      'https://dev.dukecon.org/release',
      'https://dukecon.org/javaland',
      'https://dev.dukecon.org/jfslatest',

      'https://dev.dukecon.org/jenkins/',
      'https://dev.dukecon.org/latest/',
      'https://dev.dukecon.org/testdata/',
      'https://dev.dukecon.org/testing/',
      'https://dev.dukecon.org/release/',
      'https://dukecon.org/javaland/',
      'https://dev.dukecon.org/jfslatest/',
    ],
  }

  # SSL - there can be only one!
  apache::vhost { 'ssl.dukecon.org':
    servername             =>  'dukecon.org',
    ip                     => '85.214.26.208',
    port                   =>  '443',
    ssl                    =>  true,
    ssl_cert               =>  '/etc/tls/server.pem',
    ssl_key                =>  '/etc/tls/key.pem',
    ssl_ca                 =>  '/etc/tls/startssl-chain.pem',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers        =>  [ 'set X-Forwarded-Proto https' ],
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
      { 'path'    =>  '/javaland/',
        'url'     =>  'http://localhost:9080/javaland/',
      },
      { 'path'    =>  '/jfslatest/',
        'url'     =>  'http://localhost:9051/jfslatest/',
      },
      { 'path'    =>  '/jfs/',
        'url'     =>  'http://localhost:9051/jfslatest/',
      },
    ],
    redirect_source        => ['/auth',  '/nexus',  '/latest',  '/testdata',  '/testing',  '/release',  '/javaland',  '/JavaLand', '/jfslatest',  '/jfs', ],
    redirect_dest          => ['/auth/', '/nexus/', '/latest/', '/testdata/', '/testing/', '/release/', '/javaland/', '/javaland', '/jfslatest/', '/jfs/',],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers                => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'programm.doag.org':
    servername            => 'programm.doag.org',
    ip                    => '85.214.26.208',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/doag.2015.crt',
    ssl_key               => '/etc/tls/doag2014.key',
    ssl_ca                => '/etc/tls/intermediate2015.crt',
    docroot               => '/var/www/html',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/doag/(\d+)/init.json',
        'url'  => 'http://localhost:9050/latest/rest/init/doag/$1',
      },
    ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }
} else {
  apache::vhost { 'dev.dukecon.org':
    servername             =>  'default',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    proxy_preserve_host    =>  'true',
    proxy_pass             =>  [
      { 'path'      =>  '/jenkins',
        'url'       =>  'http://localhost:8080/jenkins',
        'keywords'  =>  ['nocanon'],
      },
      { 'path'    =>  '/nexus/',
        'url'     =>  'http://localhost:8081/',
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
      { 'path'    =>  '/jfslatest/',
        'url'     =>  'http://localhost:9051/jfslatest/',
      },
    ],
    redirect_source        => ['/nexus', '/latest', '/testdata', '/testing', '/release', '/jfslatest', ],
    redirect_dest          => ['/nexus/', '/latest/', '/testdata/', '/testing/', '/release/', '/jfslatest/', ],
  }
}

apache::vhost { 'javaland-latest.dukecon.org':
  port                   => '80',
  docroot                => '/var/www/html',
  proxy_preserve_host    => 'true',
  proxy_pass_match       => [
    { 'path'  =>  '^/(\d+)/init.json',
      'url'   =>  'http://localhost:9050/latest/rest/init/javaland/$1',
    },
    { 'path'  =>  '^/(\d+)/(.*)',
      'url'   =>  'http://localhost:9050/latest/$2',
    },
  ],
  redirectmatch_regexp   => [
    '^/$',
  ],
  redirectmatch_dest     => [
    '/2017/',
  ],
  redirectmatch_status   => [
    'temp',
  ],
  proxy_pass             => [
    { 'path'    =>  '/rest/',
      'url'     =>  'http://localhost:9050/latest/rest/',
    },
  ]
}

apache::vhost { 'herbstcampus-latest.dukecon.org':
  port                   => '80',
  docroot                => '/var/www/html',
  proxy_preserve_host    => 'true',
  proxy_pass_match       => [
    { 'path'  =>  '^/(\d+)/init.json',
      'url'   =>  'http://localhost:9050/latest/rest/init/herbstcampus/$1',
    },
    { 'path'  =>  '^/(\d+)/(.*)',
      'url'   =>  'http://localhost:9050/latest/$2',
    },
  ],
  redirectmatch_regexp   => [
    '^/$',
  ],
  redirectmatch_dest     => [
    '/2017/',
  ],
  redirectmatch_status   => [
    'temp',
  ],
  proxy_pass             => [
    { 'path'    =>  '/rest/',
      'url'     =>  'http://localhost:9050/latest/rest/',
    },
  ]
}

# TODO: Move productive releases to SSL config
# TODO: Move context path "javaland" to "release" or drop it at all
apache::vhost { 'javaland.dukecon.org':
  port                   => '80',
  docroot                => '/var/www/html',
  proxy_preserve_host    => 'true',
  proxy_pass_match       => [
    { 'path'  =>  '^/(\d+)/init.json',
      'url'   =>  'http://localhost:9080/javaland/rest/init/javaland/$1',
    },
    { 'path'  =>  '^/(\d+)/(.*)',
      'url'   =>  'http://localhost:9080/javaland/$2',
    },
  ],
  redirectmatch_regexp   => [
    '^/$',
  ],
  redirectmatch_dest     => [
    '/2017/',
  ],
  redirectmatch_status   => [
    'temp',
  ],
  proxy_pass             => [
    { 'path'    =>  '/rest/',
      'url'     =>  'http://localhost:9050/latest/rest/',
    },
  ]
}

apache::vhost { 'herbstcampus.dukecon.org':
  port                   => '80',
  docroot                => '/var/www/html',
  proxy_preserve_host    => 'true',
  proxy_pass_match       => [
    { 'path'  =>  '^/(\d+)/init.json',
      'url'   =>  'http://localhost:9080/javaland/rest/init/herbstcampus/$1',
    },
    { 'path'  =>  '^/(\d+)/(.*)',
      'url'   =>  'http://localhost:9080/javaland/$2',
    },
  ],
  redirectmatch_regexp   => [
    '^/$',
  ],
  redirectmatch_dest     => [
    '/2017/',
  ],
  redirectmatch_status   => [
    'temp',
  ],
  proxy_pass             => [
    { 'path'    =>  '/rest/',
      'url'     =>  'http://localhost:9050/latest/rest/',
    },
  ]
}

