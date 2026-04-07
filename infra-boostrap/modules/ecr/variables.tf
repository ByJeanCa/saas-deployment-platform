variable "common_tags" {
  description = "Map of common tags to apply to all project resources."
  type        = map(string)
}

variable "image_names" {
  description = "List of image names to be used by the deployment."
  type        = list(string)
}