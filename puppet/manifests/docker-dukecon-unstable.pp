$instance="unstable"
$port = "9051"

docker::run { "dukecon-$instance":
  image    => "dukecon/dukecon-server:1.4-SNAPSHOT",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,docker",
    "SPRING_CONFIG_LOCATION=/opt/dukecon/config",
  ],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/opt/dukecon/logs",
    "/data/dukecon/config/dukecon-$instance:/opt/dukecon/config",
  ],
}
