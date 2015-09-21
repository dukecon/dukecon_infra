docker::run { 'dukecon-testing':
  image		=> 'ascheman/dukecon-server:latest',
  ports		=> ['9060:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=testing'],
}
