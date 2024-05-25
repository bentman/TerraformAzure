locals {
  powershell_script = [
    "New-Item c:\\BUILD\\LOGS\\ -ItemType Directory -Force -ea 0"
  ]
}
