resource "kubernetes_config_map" "scylla_dashboards" {
  metadata {
    name      = "scylla-dashboards"
    namespace = "monitoring"

    labels = {
      app = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release = "prometheus-operator"
    }
  }

  data {
    "scylla-dash.3.0.json" = "${file("${path.module}/templates/scylla-dash.3.0.json")}"
  }
}
