resource "yandex_alb_target_group" "word-g" {
  name           = "word-g"

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address   = "${yandex_compute_instance.web1.network_interface.0.ip_address}"
  }

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address   = "${yandex_compute_instance.web2.network_interface.0.ip_address}"
  }
}

resource "yandex_alb_http_router" "word-router" {
  name   = "word-router"
}

resource "yandex_alb_backend_group" "word-bg" {

  name                     = "word-bg"

  http_backend {
    name                   = "http-back"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.word-g.id]
    load_balancing_config {
      panic_threshold      = 40
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "15s"
      healthy_threshold    = 2
      unhealthy_threshold  = 3 
      http_healthcheck {
        path               = "/wp-admin/install.php"
      }
    }
  }
}


resource "yandex_alb_virtual_host" "word-virtual-host" {
  name           = "wodr-virtual-host"
  http_router_id = yandex_alb_http_router.word-router.id
  route {
    name = "socketio"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.word-bg.id
        timeout          = "10s"
        upgrade_types    = ["websocket"]
      }
    }
  }
}


resource "yandex_alb_load_balancer" "word-balancer" {
  name = "word-balancer"

  network_id = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }
  }

  listener {
    name = "http"
    endpoint {
      address {
        external_ipv4_address {
#         address = yandex_vpc_address.http.external_ipv4_address.0.address
        }
      }
    ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.word-router.id
      }
    }
  }
}