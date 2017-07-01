$instance="latest"
$port = "9050"

docker::run { "dukecon-$instance":
  image    => "dukecon/dukecon-server:latest",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,docker,private-sched-ids",
  ],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/opt/dukecon/logs",
    "/data/dukecon/config-common:/opt/dukecon/config",
  ],
}
