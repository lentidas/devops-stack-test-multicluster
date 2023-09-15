locals {
  app_autosync = var.enable_app_autosync ? { allow_empty = false, prune = true, self_heal = true } : {}
}
