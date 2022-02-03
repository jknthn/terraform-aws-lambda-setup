variable "function_path" {
  description = "A path to the directory containing funciton code"
  type = string
}

variable "shared_paths" {
  description = "Path of python folders with code shared between lambdas"
  type = list(string)
  default = []
}

variable "test_paths" {
  description = "Path of python test folders to run"
  type = list(string)
  default = []
}

variable "function_name" {
  description = "Function name"
  type = string
}
