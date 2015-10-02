include apache

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
	'url'		=>	'http://localhost:9051/testdata/',
    },
    {	'path'		=>	'/testing/',
	'url'		=>	'http://localhost:9060/testing/',
    },
    {	'path'		=>	'/release/',
	'url'		=>	'http://localhost:9070/release/',
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
}
