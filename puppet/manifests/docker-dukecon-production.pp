docker::run { 'dukecon-production':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9080:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=production'],
}
