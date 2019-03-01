resource "kubernetes_config_map" "redis_dashboard" {
  metadata {
    name      = "redis-dashboard"
    namespace = "monitoring"

    labels = {
      app = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release = "prometheus-operator"
    }
  }

  data {
    "redis.json" = "${file("${path.module}/templates/redis-dashboard.json")}"
  }
}
