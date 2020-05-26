resource "kubernetes_config_map" "scylla_dashboards" {
  metadata {
    name      = "scylla-dashboards"
    namespace = "monitoring"

    labels = {
      app               = "prometheus-operator-grafana"
      grafana_dashboard = "1"
      release           = "prometheus-operator"
    }
  }

  data = {
    "scylla-cpu.2019.1.json"    = file("${path.module}/templates/scylla-cpu.2019.1.json")
    "scylla-cql.2019.1.json" = file("${path.module}/templates/scylla-cql.2019.1.json")
    "scylla-detailed.2019.1.json" = file("${path.module}/templates/scylla-detailed.2019.1.json")
    "scylla-errors.2019.1.json" = file("${path.module}/templates/scylla-errors.2019.1.json")
    "scylla-io.2019.1.json" = file("${path.module}/templates/scylla-io.2019.1.json")
    "scylla-os.2019.1.json" = file("${path.module}/templates/scylla-os.2019.1.json")
    "scylla-overview.2019.1.json" = file("${path.module}/templates/scylla-overview.2019.1.json")
    "scylla-manager.2.0.json" = file("${path.module}/templates/scylla-manager.2.0.json")
  }
}
