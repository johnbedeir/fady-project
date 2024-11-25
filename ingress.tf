################################################################################
# Nginx Ingress Configurations
################################################################################

resource "helm_release" "nginx_ingress" {
  name       = var.ingress_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = var.ingress_chart_name
  namespace  = var.kube_namespace

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.config.use-proxy-protocol"
    value = "true"
  }
}
