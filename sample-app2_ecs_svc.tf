### ALB

resource "aws_alb" "sample-app2-alb" {
  name            = "sample-app2-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

resource "aws_route53_record" "sample-app2-r53-alias" {
  zone_id = "Z2MROSIUDOXQZV"
  name    = "sample-app2-r53-alias"
  type    = "A"

  alias {
    name                   = "${aws_alb.sample-app2-alb.dns_name}"
    zone_id                = "${aws_alb.sample-app2-alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_alb_target_group" "sample-app2-tg" {
  name        = "sample-app2-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"

  health_check {
    path = "/sample-app2/health"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "sample-app2-alb-listener" {
  load_balancer_arn = "${aws_alb.sample-app2-alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.sample-app2-tg.id}"
    type             = "forward"
  }
}

### ECS

resource "aws_ecs_cluster" "sample-app2-ecs-cluster" {
  name = "fargate-poc"
}

resource "aws_ecs_task_definition" "sample-app2-ecs-td" {
  family                   = "sample-app2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn            = "arn:aws:iam::747995093890:role/sample-apps-role"
  execution_role_arn       = "arn:aws:iam::747995093890:role/sample-apps-role"

  container_definitions = "${file("task-definitions/sample-app2-td.json")}"
}

resource "aws_ecs_service" "sample-app2-ecs-service" {
  name            = "sample-app2-service"
  cluster         = "${aws_ecs_cluster.sample-app2-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.sample-app2-ecs-td.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.sample-app2-tg.id}"
    container_name   = "sample-app2"
    container_port   = "${var.sample_app2_port}"
  }

  depends_on = [
    "aws_alb_listener.sample-app2-alb-listener",
  ]
}
