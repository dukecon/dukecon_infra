include apache

apache::vhost { 'dev.dukecon.org':
  port		=>	'80',
  docroot	=>	'/var/www/html',
  proxy_pass	=>	[
    {	'path'	=>	'/nexus',
	'url'	=>	'http://localhost:8081',
    },
    {	'path'	=>	'/latest',
	'url'	=>	'http://localhost:9090',
    },
  ]
}
