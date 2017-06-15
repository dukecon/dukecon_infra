$instance = "production"
$port = "9080"

docker::run { "dukecon-$instance":
  image    => "ascheman/dukecon-server:release",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,postgresql,docker",
    # TODO: This is only a workaround!
    "DUKECON_ARGS='--postgres.host=postgres --postgres.port=5432'",
  ],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/opt/dukecon/logs",
  ],
  links    => ["dukecon-postgres-$instance:postgres",],
  depends  => ["dukecon-postgres-$instance",],
}
