docker::run { 'dukecon-release':
  image		=> 'ascheman/dukecon-server:latest-release-candidate',
  ports		=> ['9070:8080'],
  env		=> ['SPRING_PROFILES_ACTIVE=release'],
  volumes       => ['/data/dukecon/cache/dukecon-release:/var/cache/dukecon'],
}
