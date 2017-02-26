# Default: ensure latest version!

Package {
    ensure 	=> "latest"
}

# Should be already there through "init-puppet-debian.sh"
package { "git": }
package { "etckeeper": }
# The minimal set of packages we would like to see!
package { "screen": }
package { "apticron": }

# Tweak etckeeper
file_line { 'etckeeper:git':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'VCS="git"',
  require => Package['etckeeper']
}
file_line { 'etckeeper:no-nightly-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_DAILY_AUTOCOMMITS=1',
  match 	=> '#AVOID_DAILY_AUTOCOMMITS=1',
  require => Package['etckeeper']
}
file_line { 'etckeeper:no-auto-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_COMMIT_BEFORE_INSTALL=1',
  match 	=> '#AVOID_COMMIT_BEFORE_INSTALL=1',
  require => Package['etckeeper']
}

# Install hiera (at least to make warnings disappear :-)
file { 'hiera.yaml':
  path		=> '/etc/puppet/hiera.yaml',
  owner		=> 'root',
  group		=> 'root',
  mode		=> 0444,
  content	=> '---
:backends:
  - yaml

:logger: console

:hierarchy:
  - "%{operatingsystem}"
  - common

:yaml:
   :datadir: /etc/puppet/hieradata
',
}

file { '/etc/puppet/hieradata':
  ensure   => 'directory',
  owner    => 'root',
  group    => 'root',
  mode     => 0755
}

# Only create it if it does not yet exist!
exec { 'create /etc/puppet/hieradata/common.yaml':
  unless   => '/usr/bin/test -s /etc/puppet/hieradata/common.yaml',
  command  => '/bin/cat >/etc/puppet/hieradata/common.yaml<<EOF
dukecon:
    apache:
        ssl: false
EOF',
  require  => File['/etc/puppet/hieradata'],
}

# Enable puppet future parser (experimental in Puppet 3.x >= 3.2, cf. https://docs.puppet.com/puppet/3/experiments_lambdas.html)
ini_setting { "future parser for puppet":
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'parser',
  value   => 'future',
}