resource "aws_autoscaling_group" "spots" {
  count = var.spot_enabled ? 1 : 0
  name_prefix = format("%s-spots", var.project_name)
  vpc_zone_identifier = var.asg_vpc_zone_identifier
  desired_capacity = var.cluster_spot_desired_size
  max_size         = var.cluster_spot_max_size
  min_size         = var.cluster_spot_min_size

  launch_template {
    id      = aws_launch_template.spots[0].id
    version = aws_launch_template.spots[0].latest_version
  }

  tag {
    key                 = "Name"
    value               = format("%s-spots", var.project_name)
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

}

resource "aws_ecs_capacity_provider" "spots" {
  count = length(aws_autoscaling_group.spots) > 0 ? 1 : 0
  name = format("%s-spots", var.project_name)

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.spots[0].arn
    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 90
    }
  }
}