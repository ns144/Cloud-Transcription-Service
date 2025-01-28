resource "aws_autoscaling_group" "transcription-servers" {
    name = "ton-texter-transcription-servers"
    availability_zones = ["eu-central-1"]
    desired_capacity   = 0
    max_size           = 5
    min_size           = 0

    launch_template {
        name      = "ton-texter-transcription-server"
        version = "$Latest"
    }

    enabled_metrics = [
        "GroupInServiceInstances",
        "GroupTotalInstances",
        "GroupTerminatingInstances",
    ]

    tag {
            key                 = "Name"
            value               = "ton-texter-transcription-server"
            propagate_at_launch = true
        }
}