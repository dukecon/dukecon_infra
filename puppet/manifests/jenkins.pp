include jenkins

class { 'maven': }

package { 'git' :
  ensure => installed,
}

$plugins = [
  'git-client',
  'scm-api',
  'git',
  'jquery',
  'jobConfigHistory',
  'build-pipeline-plugin',
  'disk-usage',
  'monitoring',
  'ColumnsPlugin',
  'envinject',
]
  
jenkins::plugin { $plugins : }
