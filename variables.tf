variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "avijitsarkar123/sample-app3:0.0.1-SNAPSHOT"
}

variable "sample_app1_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8081
}

variable "sample_app2_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8082
}

variable "sample_app3_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8083
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}
