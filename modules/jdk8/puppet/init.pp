$hiera_java_jdk_avoid_oracle_jdk = lookup('java.jdk.avoid_oracle_jdk', Boolean, 'deep', true)

if $hiera_java_jdk_avoid_oracle_jdk {
  class { 'java' :
    package => 'java-1.8.0-openjdk-devel',
  }
} else {
  # This is not automatically installed on all Ubuntu 14.x / Debian ...
  package { "software-properties-common": }

  include oraclejdk8

  oraclejdk8::install{ '/usr/lib/jvm/java-8-oracle':
    set_default_env => true,
    require         => [
      Package['software-properties-common'],
    ]
  }
}
