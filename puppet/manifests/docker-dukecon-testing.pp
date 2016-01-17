$instance = "testing"

docker::run { "dukecon-$instance":
  image		=> "ascheman/dukecon-server:latest",
  ports		=> ["9060:8080"],
  env		  => ["SPRING_PROFILES_ACTIVE=$instance,postgres"],
  volumes => ["/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon"],
  links   => ["dukecon-postgres-$instance:postgres",],
  depends	=> ["dukecon-postgres-$instance",],
}
