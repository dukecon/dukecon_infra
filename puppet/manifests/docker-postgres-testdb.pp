file { '/data/postgresql':
  path          =>      '/data/postgresql',
  ensure        =>      directory,
  mode          =>      0755,
}

file { '/data/postgresql/testdb':
  path          =>      '/data/postgresql/testdb',
  ensure        =>      directory,
  mode          =>      0755,
  require	=>	File['/data/postgresql'],
}

file { '/data/postgresql/testdb/data':
  path          =>      '/data/postgresql/testdb/data',
  ensure        =>      directory,
  mode          =>      0700,
  require	=>	File['/data/postgresql/testdb'],
}

docker::run { 'postgres-testdb':
  image         => 'postgres:9.4',
  volumes       => ['/data/postgresql/testdb/data:/var/lib/postgresql/data'],
  ports         => ['127.0.0.1:8432:5432'],
  env           => ['POSTGRES_USER=dukecon', 'POSTGRES_PASSWORD=dukecon'],
  require	=> File['/data/postgresql/testdb/data'],
}
