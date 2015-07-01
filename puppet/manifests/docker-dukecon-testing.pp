docker::run { 'dukecon-testing':
  image		=> 'ascheman/dukecon-server',
  ports		=> ['9080:8080'],
}
