include apache

apache::vhost { 'dev.dukecon.org':
  port		=>	'80',
  docroot	=>	'/var/www/html',
  proxy_pass	=>	[
    {	'path'	=>	'/latest',
	'url'	=>	'http://localhost:9090',
    },
  ]
}
