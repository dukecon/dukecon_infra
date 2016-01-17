docker::run { 'dukecon-testdata':
  image		=> 'ascheman/dukecon-server:latest',
  ports		=> ['9040:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=testdata'],
  volumes       => ['/data/dukecon/cache/dukecon-testdata:/var/cache/dukecon'],
}
