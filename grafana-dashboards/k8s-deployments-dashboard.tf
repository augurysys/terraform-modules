resource "kubernetes_config_map" "k8s_deployments_dashboard" {
  metadata {
    name      = "k8s-deployments-dashboard"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data = {
    "k8s-deployments.json" = file("${path.module}/templates/k8s-deployments-dashboard.json")
  }
}
