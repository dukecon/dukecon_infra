# TODO: Check lookup mechanisms of Hiera for nested data!
$hiera_java_jdk_avoid_oracle_jdk = hiera('java::jdk::avoid_oracle_jdk', false)

if !$hiera_java_jdk_avoid_oracle_jdk {
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