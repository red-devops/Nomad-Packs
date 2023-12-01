variable "job_name" {
  # If "", the pack name will be used
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
}

variable "environment" {
  description = "The environment where jobs will be deployed"
  type        = string
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "=",
    },
    {
      attribute = "$${meta.public}",
      value     = "false",
      operator  = "=",
    }
  ]
}

variable "docker_image" {
  description = "Address of the docker image"
  type        = string
  default     = "ghcr.io/red-devops/workoutrecorder-frontend"
}

variable "docker_image_version" {
  description = "Version of the docker image"
  type        = string
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 2
}

variable "register_service" {
  description = "If you want to register a Nomad service for the job"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "The service name for the workoutrecorder_frontend application"
  type        = string
  default     = "workoutrecorder-frontend"
}

variable "service_tags" {
  description = "The service tags for the workoutrecorder_backend application"
  type        = list(string)
  default = [
    "frontend",
    "urlprefix-/"
  ]
}

variable "resources" {
  description = "The resource to assign to the application."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50,
    memory = 128
  }
}