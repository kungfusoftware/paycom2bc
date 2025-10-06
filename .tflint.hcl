# .tflint.hcl
config {
  # v0.54+ replacement for the old `module` setting
  call_module_type = "all"
  format           = "compact"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
  version = "0.29.0" # pin to a known release
  # signing_key = <<-KEY
  # -----BEGIN PGP PUBLIC KEY BLOCK-----
  # ... (optional; from the plugin’s releases page)
  # -----END PGP PUBLIC KEY BLOCK-----
}
