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

package { 'graphviz':
  # For dukecon/dukecon project (uses asciidoctor/plantuml)
  ensure  => installed,
}

$plugins = [
  'antisamy-markup-formatter',
  'ant',
  'apache-httpcomponents-client-4-api',
  'bouncycastle-api',
  'build-pipeline-plugin',
  'build-with-parameters',
  'ColumnsPlugin',
  'command-launcher',
  'conditional-buildstep',
#  'credentials', # This is a Puppet Jenkins Default Plugin, don't declare it twice!
  'dashboard-view',
  'description-setter',
  'disk-usage',
  'display-url-api',
  'embeddable-build-status',
  'envinject-api',
  'envinject',
  'external-monitor-job',
  'git-client',
  'github-api',
  'github',
  'git',
  'jackson2-api',
  'javadoc',
  'jgiven',
  'jobConfigHistory',
  'job-dsl',
  'jquery',
  'jsch',
  'junit',
  'ldap',
  'mailer',
  'matrix-auth',
  'matrix-project',
  'maven-plugin',
  'monitoring',
  'pam-auth',
  'parameterized-trigger',
  'plain-credentials',
  'run-condition',
  'scm-api',
  'script-security',
  'ssh-credentials',
  'structs',
  'token-macro',
  'windows-slaves',
  'workflow-api',
  'workflow-job',
  'workflow-scm-step',
  'workflow-step-api',
  'workflow-support',
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
  line  => 'JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpListenAddress=127.0.0.1 --httpPort=$HTTP_PORT --ajp13Port=${AJP_PORT:-\"-1\"} --prefix=$PREFIX"',
  match => '^JENKINS_ARGS=',
  notify  => Service['jenkins'],
  require => Package['jenkins'],
}

file {'/var/lib/jenkins/hudson.tasks.Maven.xml':
  owner   => 'jenkins',
  group   => 'jenkins',
  mode    => '0644',
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

exec {'update-java-alternatives -s java-8-oracle':
  path    => '/usr/sbin:/sbin:/usr/bin:/bin',
  require => Exec['update-java-alternatives'],
}

exec { 'wait for jenkins':
  require => Package['jenkins'],
  command => '/bin/echo "Waiting for Jenkins 60 secs to start up" && /bin/sleep 60',
}

jenkins::job { 'dukecon_jenkins_seed':
  enabled => 1,
  require => Exec['wait for jenkins'],
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
  <triggers>
    <hudson.triggers.SCMTrigger>
      <spec>H/10 * * * *</spec>
      <ignorePostCommitHooks>false</ignorePostCommitHooks>
    </hudson.triggers.SCMTrigger>
  </triggers>
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

exec { 'init dukecon jenkins jobs':
  require => [
    Jenkins::Job["dukecon_jenkins_seed"],
  ],
  command => '/usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080/jenkins build -c dukecon_jenkins_seed',
}

file_line { 'sudo docker restart for jenkins':
  path  	=> '/etc/sudoers',
  line => 'jenkins ALL = NOPASSWD: /etc/init.d/docker-dukecon-*',
}

exec {"jenkins docker group membership":
  unless => "/bin/grep -q 'docker\\S*jenkins' /etc/group",
  command => "/usr/sbin/usermod -aG docker jenkins",
  require => User['jenkins'],
}
