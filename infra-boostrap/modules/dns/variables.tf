variable "domain" {
  description = "Domain name for the application."
  type = string
}

variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

