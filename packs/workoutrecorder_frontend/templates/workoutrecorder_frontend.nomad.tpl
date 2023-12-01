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
  
  spread {
    attribute = "${platform.aws.placement.availability-zone}"
    target "eu-central-1b" {}
    target "eu-central-1a" {}
  }

  group "angular-frontend" {
    count = [[ var "count" . ]]

    network {
      port "http" {
        to = 80
      }
    }

    [[ if var "register_service" . ]]
    service {
      name = "[[ var "service_name" . ]]"
      tags = [[ var "service_tags" . | toStringList ]]
      provider = "consul"
      port = "http"
      check {
        name     = "app_health"
        type     = "tcp"
        path     = "/"
        interval = "20s"
        timeout  = "5s"
      }
    }
    [[ end ]]

    task "angular-frontend" {
      driver = "docker"

      config {
        image = "[[ var "docker_image" . ]]:[[ var "docker_image_version" . ]]"
        ports = ["http"]
      }

      resources {
          cpu    = "[[ var "resources.cpu" . ]]"
          memory = "[[ var "resources.memory" . ]]"
      }
    }
  }
}
