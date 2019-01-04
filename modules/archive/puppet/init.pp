$image = 'dukecon/dukecon-resources:latest'

docker::image { $image: }

docker::run { 'dukecon-conference-archive':
  image    => $image,
  ports    => ['127.0.0.1:42080:80'],
}
