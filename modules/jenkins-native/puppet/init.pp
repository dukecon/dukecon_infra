$hiera_java_jdk_avoid_oracle_jdk = lookup('java.jdk.avoid_oracle_jdk', Boolean, 'deep', true)
if !$hiera_java_jdk_avoid_oracle_jdk {
  exec { 'update-java-alternatives -s java-8-oracle':
    path    => '/usr/sbin:/sbin:/usr/bin:/bin',
    require => Exec['update-java-alternatives'],
  }
}

$jenkins_globalJobDslSecurityConfig = "/var/lib/jenkins/javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration.xml"

$config_hash = {
  'PREFIX' => { value => '/jenkins'},
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
  # disk-usage@v0.28 does not work due to https://issues.jenkins-ci.org/browse/JENKINS-47546
  # 'disk-usage',
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

class {'jenkins':
  config_hash => $config_hash,
}

$maven_default_version = '3.5.2'

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

# Start initializing rules
file_line { 'JAVA_ARGS':
  path  => '/etc/default/jenkins',
  # Add ' -Djava.util.logging.config.file=/var/lib/jenkins/logging.properties' to enable debugging with the config like
    # .level = FINEST
    # handlers= java.util.logging.ConsoleHandler, java.util.logging.FileHandler
    #
    # java.util.logging.ConsoleHandler.level=INFO
    # java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
    #
    # java.util.logging.FileHandler.level=FINEST
    # java.util.logging.FileHandler.formatter=java.util.logging.SimpleFormatter
    # java.util.logging.FileHandler.pattern=/var/lib/jenkins/logs/debug.log
    # java.util.logging.FileHandler.limit=50000000
    # java.util.logging.FileHandler.count=5
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JAVA_ARGS="-Dhudson.model.DirectoryBrowserSupport.CSP=\"default-src \'self\'; style-src \'self\' \'unsafe-inline\';\" -Djava.awt.headless=true"',
  match => '^JAVA_ARGS=',
  notify  => Service['jenkins'],
  require => Package['jenkins'],
}
->
file_line { 'JENKINS_ARGS':
  path  => '/etc/default/jenkins',
  # headless: Allow graphs etc. to work even when an X server is present
  # CSP: content security policy - allow HTML reports for JGiven 
  line  => 'JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpListenAddress=127.0.0.1 --httpPort=$HTTP_PORT --ajp13Port=${AJP_PORT:-\"-1\"} --prefix=$PREFIX"',
  match => '^JENKINS_ARGS=',
  notify  => Service['jenkins'],
}
->
file {$jenkins_globalJobDslSecurityConfig:
  owner    => 'jenkins',
  group    => 'jenkins',
  mode     => '0600',
  content  => "<?xml version='1.0' encoding='UTF-8'?>
<javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration>
  <category class=\"jenkins.model.GlobalConfigurationCategory\$Security\"/>
  <useScriptSecurity>false</useScriptSecurity>
</javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration>"
}
->
augeas {"Disable Jenkins Job DSL security":
  lens       => 'Xml.lns',
  incl       => $jenkins_globalJobDslSecurityConfig,
  context    => "/files$jenkins_globalJobDslSecurityConfig",
  changes    => [
    'set javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration/useScriptSecurity/#text "false"',
  ],
  notify  => Service['jenkins'],
}
->
file {'/var/lib/jenkins/hudson.tasks.Maven.xml':
  owner   => 'jenkins',
  group   => 'jenkins',
  mode    => '0644',
  content => "<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>maven-$maven_default_version</name>
      <properties>
        <hudson.tools.InstallSourceProperty>
          <installers>
            <hudson.tasks.Maven_-MavenInstaller>
              <id>$maven_default_version</id>
            </hudson.tasks.Maven_-MavenInstaller>
          </installers>
        </hudson.tools.InstallSourceProperty>
      </properties>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>",
  notify  => Service['jenkins']
}
->
file {'/var/lib/jenkins/.m2':
  owner   => 'jenkins',
  group   => 'jenkins',
  ensure  => 'directory',
  mode    => '0755',
}
->
file {'/var/lib/jenkins/.m2/settings.xml':
  owner   => 'jenkins',
  group   => 'jenkins',
  mode    => '0600',
  content => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<settings xmlns=\"http://maven.apache.org/SETTINGS/1.0.0\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd\">

    <mirrors>
        <mirror>
            <id>dukecon</id>
            <url>http://localhost:8081/nexus/content/groups/public</url>
            <mirrorOf>*</mirrorOf>
        </mirror>
    </mirrors>

    <activeProfiles>
        <activeProfile>dukecon-localhost</activeProfile>
    </activeProfiles>

    <profiles>
        <profile>
            <id>dukecon-localhost</id>
            <repositories>
                <repository>
                    <id>localhost-snapshots</id>
                    <url>http://localhost:8081/nexus/content/repositories/snapshots</url>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </repository>
                <repository>
                    <id>localhost-releases</id>
                    <url>http://localhost:8081/nexus/content/repositories/releases</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>dukecon-snapshots</id>
                    <url>http://localhost:8081/nexus/nexus/content/group/public</url>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>
</settings>",
  notify  => Service['jenkins']
}
->
jenkins::plugin { $plugins : }
->
exec { 'Finish Jenkins Setup':
  command => '/bin/echo "Waiting 30 secs for Jenkins to start up" >&2 && /bin/sleep 30',
}

# Now wait until Jenkins is up and running again and start to execute Jobs then
exec { 'Wait for Jenkins':
  command => '/bin/echo "Waiting another 10 secs for Jenkins to start up" >&2 && /bin/sleep 10',
  require => Exec['Finish Jenkins Setup']
}
->
file {'/var/lib/jenkins/initfiles':
  owner   => 'jenkins',
  group   => 'jenkins',
  ensure  => 'directory',
  mode    => '0755',
}
->
file {'/var/lib/jenkins/initfiles/dukecon_jenkins_seed':
  owner   => 'jenkins',
  group   => 'jenkins',
  ensure  => 'present',
  mode    => '0644',
  content => '<?xml version="1.0" encoding="UTF-8"?>
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
->
exec { 'create job dukecon_jenkins_seed':
  # If Jenkins CLI comes back with return code 4, the seed job already exists - ignore this
  command => '/bin/sh -c "/usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080/jenkins/ -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` create-job dukecon_jenkins_seed < /var/lib/jenkins/initfiles/dukecon_jenkins_seed; if test $? -eq 4; then exit 0; else exit $?; fi"'
}
->
exec { 'init dukecon jenkins jobs':
  command => '/usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080/jenkins -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` build -s dukecon_jenkins_seed',
}

file_line { 'enable sudo docker-dukecon restart for jenkins':
  path  	=> '/etc/sudoers',
  line => 'jenkins ALL = NOPASSWD: /etc/init.d/docker-dukecon-*',
}

exec {"jenkins docker group membership":
  unless => "/bin/grep -q 'docker\\S*jenkins' /etc/group",
  command => "/usr/sbin/usermod -aG docker jenkins",
  require => User['jenkins'],
}
