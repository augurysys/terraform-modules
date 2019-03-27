resource "kubernetes_config_map" "sample_ingestion_dashboard" {
  metadata {
    name      = "sample-ingestion"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data {
    "sample-ingestion.json" = "${file("${path.module}/templates/sample-ingestion-dashboard.json")}"
  }
}
