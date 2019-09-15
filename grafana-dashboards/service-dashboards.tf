resource "kubernetes_config_map" "service_monitoring_dashboard" {
  metadata {
    name      = "service-monitoring"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data = {
    "service-monitoring.json" = file("${path.module}/templates/service-monitoring.json")
  }
}
