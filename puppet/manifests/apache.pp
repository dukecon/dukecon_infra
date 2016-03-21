$hiera_dukecon = hiera('dukecon')
$hiera_dukecon_apache = $hiera_dukecon['apache']
$hiera_dukecon_apache_ssl = $hiera_dukecon_apache['ssl']


class { 'apache':
  keepalive    =>  'On',
  default_vhost => false,
}

if $hiera_dukecon_apache_ssl {
  apache::vhost { 'dukecon.org':
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
    port     =>  '80',
    docroot  =>  '/var/www/html',
  }

  apache::vhost { 'keycloak.dukecon.org':
    port                   =>  '80',
    docroot                =>  '/var/www/html',
    allow_encoded_slashes  =>  'nodecode',
    redirect_status        =>  'permanent',
    redirect_source        =>  '/auth/',
    redirect_dest          =>  'https://keycloak.dukecon.org/auth/',
  }

  apache::vhost { 'dev.dukecon.org':
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

      '/jenkins/',
      '/latest/',
      '/testdata/',
      '/testing/',
      '/release/',
      '/javaland/',
    ],
    redirect_dest          => [
      '/nexus/',

      'https://dev.dukecon.org/jenkins',
      'https://dev.dukecon.org/latest',
      'https://dev.dukecon.org/testdata',
      'https://dev.dukecon.org/testing',
      'https://dev.dukecon.org/release',
      'https://dukecon.org/javaland',

      'https://dev.dukecon.org/jenkins/',
      'https://dev.dukecon.org/latest/',
      'https://dev.dukecon.org/testdata/',
      'https://dev.dukecon.org/testing/',
      'https://dev.dukecon.org/release/',
      'https://dukecon.org/javaland/',
    ],
  }

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
    ],
    redirect_source        => ['/auth',  '/nexus',  '/latest',  '/testdata',  '/testing',  '/release',  '/javaland',  '/JavaLand'],
    redirect_dest          => ['/auth/', '/nexus/', '/latest/', '/testdata/', '/testing/', '/release/', '/javaland/', '/javaland'],
    # http://stackoverflow.com/questions/32120129/keycloak-is-causing-ie-to-have-an-infinite-loop
    headers                => 'set P3P "CP=\"Potato\""'
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
    ],
    redirect_source        => ['/nexus', '/latest', '/testdata', '/testing', '/release'],
    redirect_dest          => ['/nexus/', '/latest/', '/testdata/', '/testing/', '/release/'],
  }
}
