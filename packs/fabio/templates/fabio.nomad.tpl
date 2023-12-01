job [[ template "job_name" . ]] {
  region      = [[ var "region" . | quote ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"

[[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
    constraint {
      attribute = [[ $constraint.attribute | quote ]]
      value     = [[ $constraint.value | quote ]]
      [[- if ne $constraint.operator "" ]]
      operator  = [[ $constraint.operator | quote ]]
      [[- end ]]
    }
    [[- end ]][[- end ]]

  group "fabio" {
    count = [[ var "count" . ]]
    
    network {
      port "lb" {
        static = 9999
      }

      port "ui" {
        static = 9998
      }
    }
    
    [[ if var "register_service" . ]]
    service {
      name = "[[ var "service_name" . ]]"
      tags = [[ var "service_tags" . | toStringList ]]
      provider = "consul"
      port = "lb"
      check {
        type     = "tcp"
        port     = "lb"
        name     = "app_health"
        interval = "20s"
        timeout  = "5s"
      }
    }
    [[ end ]]

    task "fabio" {
      driver = "docker"

      vault {
        policies = ["fabio"]
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      config {
        image   = "[[ var "docker_image" . ]]:[[ var "docker_image_version" . ]]"
        network_mode = "host"
        ports   = ["lb", "ui"]
        mount {
          type   = "bind"
          source = "local"
          target = "/etc/fabio"
        }
      }

      template {
        data = <<EOH
          registry.consul.token = {{ with secret "kv/data/consul/fabio_token"}}{{.Data.data.token}}{{end}}
          registry.consul.register.enabled = false
        EOH

        destination = "local/fabio.properties"
      }

      resources {
        cpu    = [[ var "resources.cpu" . | quote ]]
        memory = [[ var "resources.memory" . | quote ]]
      }
    }
  }
}
