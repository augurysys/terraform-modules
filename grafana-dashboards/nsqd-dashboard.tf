resource "kubernetes_config_map" "nsqd_dashboard" {
  metadata {
    name      = "nsqd-dashboard"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data {
    "nsqd.json" = "${file("${path.module}/templates/nsqd-dashboard.json")}"
  }
}
