docker::run { 'dukecon-latest':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9050:8080'],
}
