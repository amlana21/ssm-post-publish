resource "aws_service_discovery_private_dns_namespace" "nginx_dns" {
  name = "nginx.dns"
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "nginx_discovery" {
  name = "nginx"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.nginx_dns.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}