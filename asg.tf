resource "aws_autoscaling_group" "ton-texter-transcription-servers" {
    name = "ton-texter-transcription-servers"
    availability_zones    = ["eu-central-1a", "eu-central-1b"]
    max_size              = 10
    min_size              = 0
    protect_from_scale_in = true

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