resource "google_service_account" "service_account" {
  account_id   = var.id
  display_name = var.name
}

resource "google_service_account_key" "service_account_key" {
  service_account_id = google_service_account.service_account.name
}

#resource "kubernetes_secret" "service_account_secret" {
#  metadata {
#    name = "${var.id}-service-account"
#  }
#
#  data = {
#    "service-account.json" = base64decode(google_service_account_key.service_account_key.private_key)
#  }
#}
