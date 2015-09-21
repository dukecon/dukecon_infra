docker::run { 'dukecon-latest':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9050:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=latest,noauth'],
}
