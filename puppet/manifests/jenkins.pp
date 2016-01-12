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
  'jgiven',
  'monitoring',
  'ColumnsPlugin',
  'envinject',
]
  
jenkins::plugin { $plugins : }
