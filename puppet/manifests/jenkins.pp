include jenkins

class { 'maven': }

package { 'git' :
  ensure => installed,
}

# firefox is needed for GUI test of dukecon
package { 'firefox':
  ensure => 'latest',
}

# used for headless testing
package { 'xvfb':
  ensure => 'installed'
}

$plugins = [
  'git-client',
  'scm-api',
  'git',
  'jquery',
  'jobConfigHistory',
  'build-pipeline-plugin',
  'disk-usage',
  'jgiven',
  'monitoring',
  'ColumnsPlugin',
  'envinject',
]
  
jenkins::plugin { $plugins : }

file_line { 'JAVA_ARGS':
  path  => '/etc/default/jenkins',
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JAVA_ARGS="-Dhudson.model.DirectoryBrowserSupport.CSP=\"default-src \'self\'; style-src \'self\' \'unsafe-inline\';\" -Djava.awt.headless=true"',
  match => '^JAVA_ARGS=',
  notify  => Service['jenkins'],
}


file_line { 'JENKINS_ARGS':
  path  => '/etc/default/jenkins',
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT --prefix=$PREFIX"',
  match => '^JENKINS_ARGS=',
  notify  => Service['jenkins'],
}
