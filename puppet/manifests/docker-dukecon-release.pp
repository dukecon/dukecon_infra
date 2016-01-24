$instance = "release"
$port = "9070"

docker::run { "dukecon-$instance":
  image    => "ascheman/dukecon-server:release-candidate",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,postgresql,docker",
    # TODO: This is only a workaround!
    "DUKECON_ARGS='--postgres.host=postgres --postgres.port=5432'",
  ],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/logs",
  ],
  links    => ["dukecon-postgres-$instance:postgres",],
  depends  => ["dukecon-postgres-$instance",],
}
