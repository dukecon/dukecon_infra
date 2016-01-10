docker::run { 'dukecon-latest':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9050:8080'],
  volumes   => ['/data/dukecon/cache/dukecon-latest:/var/cache/dukecon'],
  env		=> ['SPRING_PROFILES_ACTIVE=latest,noauth'],
}
