$instance = "testing"
$port = 9062

file { "/data/postgresql":
  path          =>      "/data/postgresql",
  ensure        =>      directory,
  mode          =>      0755,
}

file { "/data/postgresql/dukecon":
  path          =>      "/data/postgresql/dukecon",
  ensure        =>      directory,
  mode          =>      0755,
  require	=>	File["/data/postgresql"],
}

file { "/data/postgresql/dukecon/$instance":
  path          =>      "/data/postgresql/dukecon/$instance",
  ensure        =>      directory,
  mode          =>      0755,
  require	=>	File["/data/postgresql/dukecon"],
}

file { "/data/postgresql/dukecon/$instance/data":
  path          =>      "/data/postgresql/dukecon/$instance/data",
  ensure        =>      directory,
  mode          =>      0700,
  require	=>	File["/data/postgresql/dukecon/$instance"],
}

docker::run { "dukecon-postgres-$instance":
  image         => "postgres:9.3",
  volumes       => ["/data/postgresql/dukecon/$instance/data:/var/lib/postgresql/data"],
  ports         => ["127.0.0.1:${port}:5432"],
  env           => ["POSTGRES_USER=dukecon", "POSTGRES_PASSWORD=dukecon"],
  require	=> File["/data/postgresql/dukecon/$instance/data"],
}
