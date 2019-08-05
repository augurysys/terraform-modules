resource "kubernetes_config_map" "nginx_ingress_dashboard" {
  metadata {
    name      = "nginx-ingress-dashboard"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data = {
    "nginx-ingress.json" = file("${path.module}/templates/nginx-ingress-dashboard.json")
  }
}
