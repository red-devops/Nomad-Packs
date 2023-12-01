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

  group "java-backend" {
    count = [[ var "count" . ]]
    
    network {
      port "http" {
        to = 8080
      }
    }
    
    [[ if var "register_service" . ]]
    service {
      name = "[[ var "service_name" . ]]"
      tags = [[ var "service_tags" . | toStringList ]]
      provider = "consul"
      port = "http"
      check {
        type     = "http"
        port     = "http"
        name     = "app_health"
        path     = "/actuator/health"
        interval = "20s"
        timeout  = "5s"
      }
    }
    [[ end ]]

    task "java-backend" {
      driver = "docker"

      config {
        image = "[[ var "docker_image" . ]]:[[ var "docker_image_version" . ]]"
        args = [
          "java",
          "-jar",
          "workoutrecorder-backend-[[ var "docker_image_version" . ]].jar"
        ]
        ports = ["http"]
      }

       vault {
        policies      = ["workoutrecorder"]
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      template {
        data        = <<EOH
        {{with secret "kv/data/workoutrecorder/db_workoutrecorder"}}
          SPRING_DATASOURCE_USERNAME="{{.Data.data.username}}"
          SPRING_DATASOURCE_PASSWORD="{{.Data.data.password}}"
        {{end}}
        SPRING_DATASOURCE_URL="jdbc:mysql://{{key "config/workoutrecorder/database-endpoint"}}/workoutrecorder?autoReconect=true"
        EOH
        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = "[[ var "resources.cpu" . ]]"
        memory = "[[ var "resources.memory" . ]]"
      }

    }
  }
}
