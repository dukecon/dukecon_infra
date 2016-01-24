$instance = "testdata"
$port = "9040"

docker::run { "dukecon-$instance":
  image    => "ascheman/dukecon-server:latest",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,docker",
  ],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/logs",
  ],
}
