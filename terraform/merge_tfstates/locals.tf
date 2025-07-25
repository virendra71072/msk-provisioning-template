locals {
  msk_regions = compact([var.primary_region, var.secondary_region])
}