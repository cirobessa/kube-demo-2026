resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
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

  depends_on = [
    aws_eks_node_group.this,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy,
  ]
}
