# Default: ensure latest version!

Package {
    ensure 	=> "latest"
}

# Delete some default packages ...
package { 'nfs-common':
  ensure  => "purged"
}
package { 'rpcbind':
  ensure  => "purged"
}

# The minimal set of packages we would like to see!
package { "git": }
# package { "etckeeper": } - is implicitely declared!
package { "screen": }
package { "apticron": }

# Some Packages required for testing
package { "libwww-mechanize-perl": }
package { "libtest-html-content-perl": }

# Minimal hiera + puppet setup (at least to make warnings disappear :-)
file { '/etc/puppet/hiera.yaml':
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
->
file { '/etc/hiera.yaml':
  ensure  => 'link',
  target  => 'puppet/hiera.yaml',
}
->
file { '/etc/puppet/hieradata':
  ensure   => 'directory',
  owner    => 'root',
  group    => 'root',
  mode     => 0755
}
->
# Only create it if it does not yet exist!
exec { 'create /etc/puppet/hieradata/common.yaml':
  unless   => '/usr/bin/test -r /etc/puppet/hieradata/common.yaml',
  command  => '/bin/cat >/etc/puppet/hieradata/common.yaml<<EOF
dukecon:
    apache:
        ssl: false
EOF
',
}
->
# Enable puppet future parser (experimental in Puppet 3.x >= 3.2, cf. https://docs.puppet.com/puppet/3/experiments_lambdas.html)
ini_setting { "future parser for puppet":
  ensure  => present,
  path    => '/etc/puppet/puppet.conf',
  section => 'main',
  setting => 'parser',
  value   => 'future',
}

include etckeeper

# Tweak etckeeper
file_line { 'etckeeper:git':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'VCS="git"',
  require => [
    Package['etckeeper'],
    Package['git'],
  ],
}
->
file_line { 'etckeeper:no-nightly-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_DAILY_AUTOCOMMITS=1',
  match 	=> '#AVOID_DAILY_AUTOCOMMITS=1',
}
->
file_line { 'etckeeper:no-auto-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_COMMIT_BEFORE_INSTALL=1',
  match 	=> '#AVOID_COMMIT_BEFORE_INSTALL=1',
}
->
exec { 'etckeeper-init-git':
  command  => 'git init',
  creates  => '/etc/.git',
  cwd      => '/etc',
  path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}
->
exec { 'etckeeper-initial-commit':
  command  => 'git commit -m "Initial commit"',
  creates  => '/etc/.git/refs/heads/master',
  cwd      => '/etc',
  path     => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
}

