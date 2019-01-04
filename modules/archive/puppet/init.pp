$image = 'dukecon/dukecon-resources:latest'

docker::image { $image: }

docker::run { 'dukecon-conference-archive':
  image    => $image,
  ports    => ['42080:80'],
}
