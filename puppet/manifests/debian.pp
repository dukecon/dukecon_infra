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
}
file_line { 'etckeeper:no-nightly-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_DAILY_AUTOCOMMITS=1',
  match 	=> '#AVOID_DAILY_AUTOCOMMITS=1',
}
file_line { 'etckeeper:no-auto-commit':
  path  	=> '/etc/etckeeper/etckeeper.conf',
  line  	=> 'AVOID_COMMIT_BEFORE_INSTALL=1',
  match 	=> '#AVOID_COMMIT_BEFORE_INSTALL=1',
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
