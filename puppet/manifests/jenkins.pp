$config_hash = {
  'PREFIX' => { value => '/jenkins'},
}

class {'jenkins':
  config_hash => $config_hash,
}

class { 'maven': }

package { 'git' :
  ensure => installed,
}

package { 'augeas-tools':
  # For command line config file evaluation and editing
  ensure  => installed,
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
  'build-pipeline-plugin',
  'ColumnsPlugin',
  'dashboard-view',
  'disk-usage',
  'description-setter',
  'embeddable-build-status',
  'envinject',
  'git',
  'git-client',
  'github',
  'jgiven',
  'jquery',
  'job-dsl',
  'jobConfigHistory',
  'parameterized-trigger',
  'monitoring',
  'scm-api',
]

jenkins::plugin { $plugins : }

file_line { 'JAVA_ARGS':
  path  => '/etc/default/jenkins',
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JAVA_ARGS="-Dhudson.model.DirectoryBrowserSupport.CSP=\"default-src \'self\'; style-src \'self\' \'unsafe-inline\';\" -Djava.awt.headless=true"',
  match => '^JAVA_ARGS=',
  notify  => Service['jenkins'],
  require => Package['jenkins'],
}

file_line { 'JENKINS_ARGS':
  path  => '/etc/default/jenkins',
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpListenAddress=127.0.0.1 --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT --prefix=$PREFIX"',
  match => '^JENKINS_ARGS=',
  notify  => Service['jenkins'],
  require => Package['jenkins'],
}

file {'/var/lib/jenkins/hudson.tasks.Maven.xml':
  owner   => 'jenkins',
  group   => 'jenkins',
  mode    => 0644,
  content => "<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>maven-3.2.5</name>
      <home>/opt/apache-maven-3.2.5</home>
      <properties/>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>",
  require => Package['jenkins'],
  notify  => Service['jenkins']
}

augeas { "add oracle jdk to jenkins":
  lens    => "Xml.lns",
  require => Package['jenkins'],
  incl    => "/var/lib/jenkins/config.xml",
  changes => [
    'defnode jdks /files/var/lib/jenkins/config.xml/hudson/jdks "#empty"',
    'clear $jdks',
    'defnode oraclejdk8 $jdks/jdk[name/#text="oraclejdk8"] "#empty"',
    'clear $oraclejdk8',
    'set $oraclejdk8/name/#text "oraclejdk8"',
    'set $oraclejdk8/home/#text "/usr/lib/jvm/java-8-oracle"'
  ],
  notify  => Service['jenkins']
}

exec {'update-java-alternatives -s java-8-oracle':
  path    => '/usr/sbin:/sbin:/usr/bin:/bin',
  require => Exec['update-java-alternatives'],
}

jenkins::job { 'dukecon_develop_seed':
  enabled => 1,
  require => Service['jenkins'],
  config  => '<?xml version="1.0" encoding="UTF-8"?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.disk__usage.DiskUsageProperty/>
  </properties>
  <scm class="hudson.plugins.git.GitSCM">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/dukecon/dukecon_jenkins.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <javaposse.jobdsl.plugin.ExecuteDslScripts>
      <targets>**.groovy</targets>
      <usingScriptText>false</usingScriptText>
      <ignoreExisting>false</ignoreExisting>
      <removedJobAction>IGNORE</removedJobAction>
      <removedViewAction>IGNORE</removedViewAction>
      <lookupStrategy>JENKINS_ROOT</lookupStrategy>
      <additionalClasspath></additionalClasspath>
    </javaposse.jobdsl.plugin.ExecuteDslScripts>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>'
}

jenkins::cli::exec { 'init dukecon develop jobs':
  require => Jenkins::Job["dukecon_develop_seed"],
  command => 'build dukecon_develop_seed',
}