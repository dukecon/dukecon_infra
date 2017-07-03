$instance="jfs"
$port = "9052"

docker::run { "dukecon-$instance":
  image    => "dukecon/dukecon-server:1.4-SNAPSHOT",
  ports    => ["127.0.0.1:$port:8080"],
  env      => [
    "SPRING_PROFILES_ACTIVE=$instance,docker",
    "JAVA_OPTS='-javaagent:/opt/inspectit/agent/inspectit-agent.jar -Dinspectit.repository=inspectit:9070 -Dinspectit.agent.name=DukeCon-$instance'",
  ],
  links    => ["inspectit"],
  volumes  => [
    "/data/dukecon/cache/dukecon-$instance:/var/cache/dukecon",
    "/data/dukecon/logs/dukecon-$instance:/opt/dukecon/logs",
    "/data/dukecon/config-common:/opt/dukecon/config",
    "/opt/inspectit/agent:/opt/inspectit/agent",
  ],
}

