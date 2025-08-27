variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "envs" {
  description = "Environment variables for the container apps"
  type        = map(string)
}

variable "app_name" {
  description = "Name of the container app"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the container app environment"
  type        = string
}

variable "target_port" {
  description = "Target port for the container app"
  type        = number
}