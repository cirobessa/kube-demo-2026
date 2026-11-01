resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name                           = "monitoring"
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/part-of"    = var.project_name
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/created-by" = "github-actions"
      environment                    = var.environment
      cost-center                    = var.cost_center
      cloud-provider                 = var.cloud_provider
      source-project                 = var.project_name
      owner                          = var.owner
    }
  }
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "prometheus" {
  name            = "prometheus"
  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "prometheus"
  namespace       = kubernetes_namespace.monitoring.metadata[0].name
  version         = "25.27.0"
  wait            = false
  cleanup_on_fail = true
  force_update    = true

  set {
    name  = "server.persistentVolume.enabled"
    value = "false"
  }
  set {
    name  = "alertmanager.persistentVolume.enabled"
    value = "false"
  }
  set {
    name  = "alertmanager.persistence.enabled"
    value = "false"
  }

  depends_on = [
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
  ]
}
