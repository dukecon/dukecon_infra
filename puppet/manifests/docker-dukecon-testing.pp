docker::run { 'dukecon-testing':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9060:8080'],
}
