docker::image { 'sonatype/nexus': }

docker::run { 'nexus':
  image		=> 'sonatype/nexus',
  volumes       => ['/data/sonatype:/sonatype-work'],
  ports		=> ['8081:8081'],
}
