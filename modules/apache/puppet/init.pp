$hiera_dukecon_apache_ssl = lookup('dukecon.apache.ssl', Boolean, 'deep', false) #, Hash[String, Any], 'unique')

class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

if $hiera_dukecon_apache_ssl {
  apache::vhost { 'dukecon.org':
    ip                     => '94.130.153.250',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    redirect_status        =>  'permanent',
    redirect_source        => [
      '/javaland',
      '/javaland/',
      '/JavaLand',
    ],
    redirect_dest          => [
      'https://dukecon.org/javaland',
      'https://dukecon.org/javaland/',
      'https://dukecon.org/javaland',
    ],
  }

  apache::vhost { 'www.dukecon.org':
    ip                     => '94.130.153.250',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
  }

  apache::vhost { 'keycloak.dukecon.org':
    ip                     => '94.130.153.250',
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    redirect_status        =>  'permanent',
    redirect_source        =>  '/',
    redirect_dest          =>  'https://keycloak.dukecon.org/',
  }

  apache::vhost { 'dev.dukecon.org':
    ip                     => '94.130.153.250',
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
      '/grafana',

      '/jenkins/',
      '/latest/',
      '/testdata/',
      '/testing/',
      '/release/',
      '/javaland/',
      '/grafana/',
    ],
    redirect_dest          => [
      '/nexus/',

      'https://dev.dukecon.org/jenkins',
      'https://dev.dukecon.org/latest',
      'https://dev.dukecon.org/testdata',
      'https://dev.dukecon.org/testing',
      'https://dev.dukecon.org/release',
      'https://dukecon.org/javaland',
      'https://dev.dukecon.org/grafana/',

      'https://dev.dukecon.org/jenkins/',
      'https://dev.dukecon.org/latest/',
      'https://dev.dukecon.org/testdata/',
      'https://dev.dukecon.org/testing/',
      'https://dev.dukecon.org/release/',
      'https://dukecon.org/javaland/',
      'https://dev.dukecon.org/grafana/',
    ],
  }

  # Iterate over an array is experimental in puppet 3.x - cf. https://docs.puppet.com/puppet/3/experiments_lambdas.html
  $sslnames = ['', "dev.", "keycloak."]
  $sslnames.each |$sslname| {
    apache::vhost { "ssl-${sslname}dukecon.org":
      servername            => "${sslname}dukecon.org",
      ip                    => '94.130.153.250',
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
        { 'path'  =>  '^/javaland/(.*)',
          'url'   =>  'http://localhost:9080/javaland/$1',
        },
        { 'path'          =>  '^/testing/(.*)',
          'url'           =>  'http://localhost:9060/$1',
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
          'url'           =>  'http://localhost:9041/auth/',
          'reverse_urls'  =>  'http://localhost:9041/auth/',
        },
        { 'path' => '/latest/',
          'url'  => 'http://localhost:9050/',
        },
        { 'path' => '/javaland/rest/init.json',
          'url'  => 'http://localhost:9080/javaland/rest/init/javaland/2016',
        },
        { 'path'     => '/grafana/',
          'url'      => 'http://localhost:3000/',
        },
      ],
      redirect_source        => ['/auth',  '/nexus',  '/latest',  '/testing',  '/javaland',  '/JavaLand',],
      redirect_dest          => ['/auth/', '/nexus/', '/latest/', '/testing/', '/javaland/', '/javaland',],
      # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
      headers                => 'set P3P "CP=\"Potato\""'
    }
  }

  apache::vhost { 'ssl-latest.dukecon.org':
    servername            => 'latest.dukecon.org',
    ip                    => '94.130.153.250',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
    ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
    docroot               => '/data/dukecon/html/latest',
    docroot_owner         => 'jenkins',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path'      =>  '^/(.+)',
        'url'       =>  'http://localhost:9050/$1',
      },
    ],
    # The following seems a bit odd: If there are more than one conferences we need multiple redirects, e.g.,
    # for javaland: the first (ones) for outdated conferences, the last one to match everything else to the current
    # instance. For other conferences we redirect to the current one.
    redirectmatch_regexp  => ['^/$',             '^/javaland/2016$', '^/javaland/2017$', '^/javaland/?(\d+/?)?$', '^/doag/?(\d+/?)?$', '^/apex/?(\d+/?)?$', '^/datavision/?(\d+/?)?$', '^/jfs/?(\d+/?)?$', '^/herbstcampus/?(\d+/?)?$' ],
    redirectmatch_dest    => ['/javaland/2018/', '/javaland/2016/',  '/javaland/2017/' , '/javaland/2018/',       '/doag/2016/',       '/apex/2017/',       '/datavision/2017/',       '/jfs/2016/',       '/herbstcampus/2016/'       ],

    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'latest.dukecon.org':
    servername            => 'latest.dukecon.org',
    ip                    => '94.130.153.250',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://latest.dukecon.org/']
  }

  apache::vhost { 'ssl-jfs-demo.dukecon.org':
    servername            => 'jfs-demo.dukecon.org',
    ip                    => '94.130.153.250',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
    ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
    docroot               => '/data/dukecon/html/jfs-demo',
    docroot_owner         => 'jenkins',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9052/rest/init/jfs/$1',
      },
      { 'path' => '^/(\w+)/(\d+)/rest/image-resources.json',
        'url'  => 'http://localhost:9052/rest/image-resources/$1/$2',
      },
      { 'path'  =>  '^/develop/inspectIT/(.*)',
        'url'   =>  'http://localhost:9052/inspectIT/$1',
      },
      { 'path'  =>  '^/(2016|2017)/(.*)',
        'url'   =>  'http://localhost:9052/$2',
      },
    ],
    redirectmatch_regexp  => ['^/$',    '^/2016$', '^/2017$', '^/(\d+)', '^/(\d+)/'],
    redirectmatch_dest    => ['/2017/', '/2016/',  '/2017/',  '/2017/',  '/2017/'  ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'jfs-demo.dukecon.org':
    servername            => 'jfs-demo.dukecon.org',
    ip                    => '94.130.153.250',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://jfs-demo.dukecon.org/']
  }

  apache::vhost { 'ssl-jfs.dukecon.org':
    servername            => 'jfs.dukecon.org',
    ip                    => '94.130.153.250',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
    ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
    docroot               => '/data/dukecon/html/jfs',
    docroot_owner         => 'jenkins',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path' => '^/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9052/rest/init/jfs/$1',
      },
      { 'path' => '^/(\w+)/(\d+)/rest/image-resources.json',
        'url'  => 'http://localhost:9052/rest/image-resources/$1/$2',
      },
      { 'path' => '^/(\w+)/(\d+)/img/favicon.ico',
        'url'  => 'http://localhost:9052/img/$1$2/favicon/favicon.ico',
      },
      { 'path'  =>  '^/develop/inspectIT/(.*)',
        'url'   =>  'http://localhost:9052/inspectIT/$1',
      },
      { 'path'  =>  '^/(2016|2017)/(.*)',
        'url'   =>  'http://localhost:9052/$2',
      },
    ],
    redirectmatch_regexp  => ['^/$',    '^/2016$', '^/2017$', '^/(\d+)', '^/(\d+)/'],
    redirectmatch_dest    => ['/2017/', '/2016/',  '/2017/',  '/2017/',  '/2017/'  ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'jfs.dukecon.org':
    servername            => 'jfs.dukecon.org',
    ip                    => '94.130.153.250',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://jfs.dukecon.org/']
  }

  apache::vhost { 'ssl-testing.dukecon.org':
    servername            => 'testing.dukecon.org',
    ip                    => '94.130.153.250',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/local/letsencrypt/certs/dukecon.org/fullchain.pem',
    ssl_key               => '/local/letsencrypt/certs/dukecon.org/privkey.pem',
    docroot               => '/data/dukecon/testing/html',
    docroot_owner         => 'jenkins',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      =>  [
      { 'path'      =>  '^/(.+)',
        'url'       =>  'http://localhost:9060/$1',
      },
    ],
    # The following seems a bit odd: If there are more than one conferences we need multiple redirects, e.g.,
    # for javaland: the first (ones) for outdated conferences, the last one to match everything else to the current
    # instance. For other conferences we redirect to the current one.
    redirectmatch_regexp  => ['^/$',             '^/javaland/2016$', '^/javaland/2017$', '^/javaland/?(\d+/?)?$', '^/doag/?(\d+/?)?$', '^/doag/2016$', '^/apex/2017$', '^/apex/?(\d+/?)?$', '^/datavision/?(\d+/?)?$', '^/jfs/2016$', '^/jfs/?(\d+/?)?$', '^/herbstcampus/?(\d+/?)?$' ],
    redirectmatch_dest    => ['/javaland/2018/', '/javaland/2016/',  '/javaland/2017/',  '/javaland/2018/',       '/doag/2017/',       '/doag/2016/',  '/apex/2017/',  '/apex/2018/',       '/datavision/2017/',       '/jfs/2016/',  '/jfs/2017/',       '/herbstcampus/2016/'       ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'testing.dukecon.org':
    servername            => 'testing.dukecon.org',
    ip                    => '94.130.153.250',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://testing.dukecon.org/']
  }

  apache::vhost { 'ssl-programm.doag.org':
    servername            => 'programm.doag.org',
    ip                    => '94.130.153.250',
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
    ip                    => '94.130.153.250',
    port                  =>  '80',
    docroot               =>  '/var/www/html',
    allow_encoded_slashes =>  'nodecode',
    redirect_source       => ['/'],
    redirect_dest         => ['https://programm.doag.org/']
  }

  apache::vhost { 'ssl-programm.javaland.eu':
    servername            => 'programm.javaland.eu',
    ip                    => '94.130.153.250',
    port                  => '443',
    ssl                   => true,
    ssl_cert              => '/etc/tls/javaland.crt',
    ssl_key               => '/etc/tls/javaland.key',
    ssl_ca                => '/etc/tls/RapidSSL_SHA256_CA.txt',
    docroot               => '/data/dukecon/html/javaland',
    docroot_owner         => 'jenkins',
    allow_encoded_slashes => 'nodecode',
    # add "X-Forwarded-Proto: https" to all forwarded requests on this SSL port
    request_headers       => [ 'set X-Forwarded-Proto https' ],
    proxy_preserve_host   => 'true',
    proxy_pass_match      => [
      { 'path'          =>  '^/auth/',
        'url'           =>  'http://localhost:9041',
        'reverse_urls'  =>  'http://localhost:9041',
      },
      { 'path' => '^/(\d+)/rest/init.json',
        'url'  => 'http://localhost:9080/javaland/rest/init/javaland/$1',
      },
      { 'path' => '^/(\w+)/(\d+)/rest/image-resources.json',
        'url'  => 'http://localhost:9080/javaland/rest/image-resources/$1/$2',
      },
      { 'path'  =>  '^/(2016|2017)/(.*)',
        'url'   =>  'http://localhost:9080/javaland/$2',
      },
    ],
    redirectmatch_regexp  => ['^/$',    '^/2016$', '^/2017$', '^/(\d+)', '^/(\d+)/'],
    redirectmatch_dest    => ['/2017/', '/2016/',  '/2017/',  '/2017/',  '/2017/'  ],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers               => 'set P3P "CP=\"Potato\""'
  }

  apache::vhost { 'programm.javaland.eu':
    servername            => 'programm.javaland.eu',
    ip                    => '94.130.153.250',
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
        'url'     =>  'http://localhost:9080/javaland/',
      },
      { 'path'      =>  '/grafana/',
        'url'       =>  'http://localhost:3000/',
      },
    ],
    proxy_pass_match      => [
      { 'path'          =>  '^/testing/(.*)',
        'url'           =>  'http://localhost:9060/$1',
      },
    ],
    redirect_source        => ['/nexus',  '/latest',  '/testing' ],
    redirect_dest          => ['/nexus/', '/latest/', '/testing/'],
  }
}
