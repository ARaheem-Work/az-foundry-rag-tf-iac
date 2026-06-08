variable "workload_name" {
  description = "CAF workload/application identifier (for example: rag, payments, catalog)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.workload_name))
    error_message = "workload_name must be 2-20 characters using lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "CAF environment code. Allowed: dev, tst, uat, prd, sbx."
  type        = string

  validation {
    condition     = contains(["dev", "tst", "uat", "prd", "sbx"], var.environment)
    error_message = "environment must be one of: dev, tst, uat, prd, sbx."
  }
}

variable "location_short" {
  description = "CAF short Azure region code (for example: wus3, eus2)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,6}$", var.location_short))
    error_message = "location_short must be 3-6 lowercase alphanumeric characters (for example: wus3)."
  }
}

variable "instance" {
  description = "CAF instance sequence (for example: 001, 002)."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance))
    error_message = "instance must be a 3-digit numeric string (for example: 001)."
  }
}
