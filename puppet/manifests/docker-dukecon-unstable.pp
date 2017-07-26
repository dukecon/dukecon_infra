$instance="unstable"
$port = "9051"
$image = "dukecon/dukecon-server:1.4-SNAPSHOT"

file { "/data":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/dukecon":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/dukecon/$instance":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/dukecon/$instance/config":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/dukecon/$instance/cache":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
file { "/data/dukecon/$instance/logs":
  ensure        =>      directory,
  mode          =>      '0755',
}
->
docker::run { "dukecon-$instance":
  image    => $image,
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,docker",
    "SPRING_CONFIG_LOCATION=/opt/dukecon/config",
  ],
  volumes  => [
    "/data/dukecon/$instance/cache:/opt/dukecon/cache",
    "/data/dukecon/$instance/logs:/opt/dukecon/logs",
    "/data/dukecon/$instance/config:/opt/dukecon/config",
  ],
}
