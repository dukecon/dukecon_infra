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

  # Iterate over an array is experimental in puppet 3.x - cf. https://docs.puppet.com/puppet/3/experiments_lambdas.html
  $sslnames = ['', "dev.", "keycloak."]
  $sslnames.each |$sslname| {
    apache::vhost { "ssl-${sslname}dukecon.org":
      servername            => "${sslname}dukecon.org",
      ip                    => '85.214.26.208',
      port                  => '443',
      ssl                   => true,
      ssl_cert              => '/etc/tls/server.pem',
      ssl_key               => '/etc/tls/key.pem',
      ssl_ca                => '/etc/tls/startssl-chain.pem',
      docroot               => '/var/www/html',
      allow_encoded_slashes => 'nodecode',
      # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
      request_headers       => [ 'set X-Forwarded-Proto https' ],
      proxy_preserve_host   => 'true',
      proxy_pass_match      => [
        { 'path'  =>  '^/javaland/(.*)',
          'url'   =>  'http://localhost:9080/javaland/$1',
        },
      ],
      proxy_pass            => [
        { 'path'     => '/jenkins',
          'url'      => 'http://localhost:8080/jenkins',
          'keywords' => ['nocanon'],
        },
        { 'path' => '/nexus/',
          'url'  => 'http://localhost:8081/',
        },
        { 'path'          =>  '/auth/',
          'url'           =>  'http://localhost:9031/auth/',
          'reverse_urls'  =>  'http://localhost:9031/auth/',
        },
        { 'path' => '/latest/',
          'url'  => 'http://localhost:9050/latest/',
        },
        { 'path' => '/testing/',
          'url'  => 'http://localhost:9060/testing/',
        },
        { 'path' => '/javaland/rest/init.json',
          'url'  => 'http://localhost:9080/javaland/rest/init/javaland/2016',
        },
        { 'path' => '/jfslatest/',
          'url'  => 'http://localhost:9051/jfslatest/',
        },
        { 'path' => '/jfs/',
          'url'  => 'http://localhost:9051/jfslatest/',
        },
      ],
      redirect_source        => ['/auth',  '/nexus',  '/latest',  '/testing',  '/javaland',  '/JavaLand', '/jfslatest',  '/jfs', ],
      redirect_dest          => ['/auth/', '/nexus/', '/latest/', '/testing/', '/javaland/', '/javaland', '/jfslatest/', '/jfs/',],
      # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
      headers                => 'set P3P "CP=\"Potato\""'
    }
  }

  apache::vhost { 'ssl-latest.dukecon.org':
    servername            => 'latest.dukecon.org',
    ip                    => '85.214.26.208',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/server.pem',
    ssl_key               => '/etc/tls/key.pem',
    ssl_ca                => '/etc/tls/startssl-chain.pem',
    docroot               => '/var/www/html',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\w+)/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9050/latest/rest/init/$1/$2',
      },
      { 'path'  =>  '^/(javaland/2016|javaland/2017|doag/2016|apex/2017|datavision/2017|jfs/2016|herbstcampus/2016)/(.*)',
        'url'   =>  'http://localhost:9050/latest/$2',
      },
    ],
    # The following seems a bit odd: If there are more than one conferences we need multiple redirects, e.g.,
    # for javaland: the first (ones) for outdated conferences, the last one to match everything else to the current
    # instance. For other conferences we redirect to the current one.
    redirectmatch_regexp  => ['^/$',             '^/javaland/2016$', '^/javaland/?(\d+/?)?$', '^/doag/?(\d+/?)?$', '^/apex/?(\d+/?)?$', '^/datavision/?(\d+/?)?$', '^/jfs/?(\d+/?)?$', '^/herbstcampus/?(\d+/?)?$' ],
    redirectmatch_dest    => ['/javaland/2017/', '/javaland/2016/',  '/javaland/2017/',       '/doag/2016/',       '/apex/2017/',       '/datavision/2017/',       '/jfs/2016/',       '/herbstcampus/2016/'       ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'latest.dukecon.org':
    servername            => 'latest.dukecon.org',
    ip                    => '85.214.26.208',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://latest.dukecon.org/']
  }

  apache::vhost { 'ssl-testing.dukecon.org':
    servername            => 'testing.dukecon.org',
    ip                    => '85.214.26.208',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/server.pem',
    ssl_key               => '/etc/tls/key.pem',
    ssl_ca                => '/etc/tls/startssl-chain.pem',
    docroot               => '/var/www/html',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\w+)/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9060/testing/rest/init/$1/$2',
      },
      { 'path'  =>  '^/(javaland/2016|javaland/2017|doag/2016|apex/2017|datavision/2017|jfs/2016|herbstcampus/2016)/(.*)',
        'url'   =>  'http://localhost:9060/testing/$2',
      },
    ],
    # The following seems a bit odd: If there are more than one conferences we need multiple redirects, e.g.,
    # for javaland: the first (ones) for outdated conferences, the last one to match everything else to the current
    # instance. For other conferences we redirect to the current one.
    redirectmatch_regexp  => ['^/$',             '^/javaland/2016$', '^/javaland/?(\d+/?)?$', '^/doag/?(\d+/?)?$', '^/apex/?(\d+/?)?$', '^/datavision/?(\d+/?)?$', '^/jfs/?(\d+/?)?$', '^/herbstcampus/?(\d+/?)?$' ],
    redirectmatch_dest    => ['/javaland/2017/', '/javaland/2016/',  '/javaland/2017/',       '/doag/2016/',       '/apex/2017/',       '/datavision/2017/',       '/jfs/2016/',       '/herbstcampus/2016/'       ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'testing.dukecon.org':
    servername            => 'testing.dukecon.org',
    ip                    => '85.214.26.208',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://testing.dukecon.org/']
  }

  apache::vhost { 'ssl-programm.doag.org':
    servername            => 'programm.doag.org',
    ip                    => '85.214.26.208',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/doag2015.crt',
    ssl_key               => '/etc/tls/doag2014.key',
    ssl_ca                => '/etc/tls/intermediate2015.crt',
    docroot               => '/var/www/html',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\w+)/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9080/javaland/rest/init/$1/$2',
      },
      { 'path'  =>  '^/(\w+)/(\d+)/(.*)',
        'url'   =>  'http://localhost:9080/javaland/$3',
      },
    ],
    redirectmatch_regexp  => ['^/',     '^/2016', '^/2017', '^/(\d+)', '^/(\d+)/'],
    redirectmatch_dest    => ['/2017/', '/2016/', '/2017/', '/2017/',  '/2017/'  ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'programm.doag.org':
    servername            => 'programm.doag.org',
    ip                    => '85.214.26.208',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://programm.doag.org/']
  }

  apache::vhost { 'ssl-programm.javaland.eu':
    servername            => 'programm.javaland.eu',
    ip                    => '85.214.26.208',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/javaland.crt',
    ssl_key               => '/etc/tls/javaland.key',
    ssl_ca                => '/etc/tls/javaland.intermediate.crt',
    docroot               => '/var/www/html',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9080/javaland/rest/init/javaland/$1',
      },
      { 'path'  =>  '^/(2016|2017)/(.*)',
        'url'   =>  'http://localhost:9080/javaland/$2',
      },
    ],
    redirectmatch_regexp  => ['^/',     '^/2016', '^/2017', '^/(\d+)', '^/(\d+)/'],
    redirectmatch_dest    => ['/2017/', '/2016/', '/2017/', '/2017/',  '/2017/'  ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'programm.javaland.eu':
    servername            => 'programm.javaland.eu',
    ip                    => '85.214.26.208',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://programm.javaland.eu/']
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

apache::vhost { 'programm-latest.doag.org':
  port                   => '80',
  docroot                => '/var/www/html',
  proxy_preserve_host    => 'true',
  proxy_pass_match       => [
    # First: conference name
    # Second: year
    { 'path'  =>  '^/(\w+)/(\d+)/init.json',
      'url'   =>  'http://localhost:9050/latest/rest/init/$1/$2',
    },
    { 'path'  =>  '^/(\w+)/(\d+)/(.*)',
      'url'   =>  'http://localhost:9050/latest/$3',
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

