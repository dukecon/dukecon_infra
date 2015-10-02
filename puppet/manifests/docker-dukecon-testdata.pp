docker::run { 'dukecon-testdata':
  image		=> 'ascheman/dukecon-server:latest',
  ports		=> ['9051:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=testdata'],
}
