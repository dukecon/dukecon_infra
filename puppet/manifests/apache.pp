include apache

apache::vhost { 'dev.dukecon.org':
  port		=>	'80',
  docroot	=>	'/var/www/html',
  proxy_pass	=>	[
    {	'path'	=>	'/jenkins/',
	'url'	=>	'http://localhost:8080/jenkins/',
    },
    {	'path'	=>	'/nexus/',
	'url'	=>	'http://localhost:8081/',
    },
    {	'path'	=>	'/latest/',
	'url'	=>	'http://localhost:9050/',
    },
    {	'path'	=>	'/testing/',
	'url'	=>	'http://localhost:9060/',
    },
  ],
  redirect_source => ['/latest', '/testing'],
  redirect_dest   => ['/latest/', '/testing/'],
}
