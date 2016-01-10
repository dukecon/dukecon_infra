docker::run { 'dukecon-production':
  image		=> 'ascheman/dukecon-server:release',
  ports		=> ['9080:8080'],
  volumes   => ['/data/dukecon/cache/dukecon-production:/var/cache/dukecon'],
  env		=> ['SPRING_PROFILES_ACTIVE=production'],
}
