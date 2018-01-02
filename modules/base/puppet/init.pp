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

include stdlib

# The minimal set of packages we would like to see!
package { "git": }
# package { "etckeeper": } - is implicitely declared!
package { "screen": }
package { "apticron": }

# Some Packages required for testing
package { "libwww-mechanize-perl": }
package { "libtest-html-content-perl": }

# Minimal hiera + puppet setup (at least to make warnings disappear :-)
file { '/etc/puppetlabs':
  ensure   => 'directory',
  owner    => 'root',
  group    => 'root',
  mode     => '0755',
}
->
file { '/etc/puppetlabs/puppet':
  ensure   => 'directory',
  owner    => 'root',
  group    => 'root',
  mode     => '0755',
}
->
file { '/etc/puppetlabs/puppet/hiera.yaml':
  owner		=> 'root',
  group		=> 'root',
  mode		=> '0444',
  content	=> '---
version: 5
defaults:  # Used for any hierarchy level that omits these keys.
  datadir: hieradata    # This path is relative to hiera.yaml\'s directory.
  data_hash: yaml_data  # Use the built-in YAML backend.


hierarchy:
  # Some default networks for wired and wireless LAN
  - name: "Wired LAN"
    path: "networks/%{::network_eth0}.yaml"
  - name: "Wireless LAN"
    path: "networks/%{::network_eth1}.yaml"
  # This is a work around for older hiera versions! It may not work for hosts without any default network!!!
  # - "networks/$network_eth0"
  - name: "Old operating systems values"
    path: "%{operatingsystem}.yaml"

  - name: "Per-OS defaults"
    path: "os/%{facts.os.family}.yaml"
  - name: "Common data"
    path: "common.yaml"
',
}
file { '/etc/puppetlabs/puppet/hieradata':
  ensure   => 'directory',
  owner    => 'root',
  group    => 'root',
  mode     => '0755',
}
->
# Only create it if it does not yet exist!
exec { 'create /etc/puppetlabs/puppet/hieradata/common.yaml':
  unless   => '/usr/bin/test -r /etc/puppetlabs/puppet/hieradata/common.yaml',
  command  => '/bin/cat >/etc/puppetlabs/puppet/hieradata/common.yaml<<EOF
dukecon:
    apache:
        ssl: false
EOF
',
}
->
# Add Network configuration!
file { '/etc/puppetlabs/puppet/hieradata/networks':
  ensure  => 'directory',
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/puppetlabs/puppet/hieradata'],
}
->
file { '/etc/puppetlabs/puppet/hieradata/networks/10.0.2.0.yaml':
  owner    => 'root',
  group    => 'root',
  mode     => '0444',
  content  => '---
# Make use of Docker Registry on VirtualBox host!
docker:
    registry:
        mirror: 10.0.2.3:5000
',
  require => File['/etc/puppetlabs/puppet/hieradata/networks'],
}

# Enable puppet future parser (experimental in Puppet 3.x >= 3.2, cf. https://docs.puppet.com/puppet/3/experiments_lambdas.html)
ini_setting { "future parser for puppet":
  ensure  => present,
  path    => '/etc/puppetlabs/puppet/puppet.conf',
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
  match  	=> 'AVOID_COMMIT_BEFORE_INSTALL=1',
  line  	=> '#AVOID_COMMIT_BEFORE_INSTALL=1',
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

