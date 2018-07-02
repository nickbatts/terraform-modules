data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "updating system...${substr(timestamp(),0,10)}"
ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime

yum update && yum upgrade -y

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.cluster_1.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.cluster_1.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.cluster_1.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}

resource "aws_launch_configuration" "tf-eks-lc" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "DevOps"
  name_prefix                 = "tf-eks"
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"
  spot_price                  = "${var.spot_price}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-asg" {
  name                      = "tf-eks-asg"
  desired_capacity          = "${var.asg_desired_count}"
  max_size                  = 8
  min_size                  = 0
  default_cooldown          = 30
  launch_configuration      = "${aws_launch_configuration.tf-eks-lc.id}"
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${aws_subnet.public.*.id}"]
  enabled_metrics           = ["GroupTotalInstances", "GroupMaxSize", "GroupInServiceInstances", "GroupPendingInstances", "GroupDesiredCapacity", "GroupMinSize", "GroupStandbyInstances", "GroupTerminatingInstances"]

  tag {
    key                 = "Name"
    value               = "tf-eks-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Description"
    value               = "This instance is part of an auto-scaling group for EKS managed by Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Creator"
    value               = "Terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_launch_configuration.tf-eks-lc"]
}

resource "aws_security_group" "eks-node" {
  name        = "tf-eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description     = "Allow node to communicate with each other"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
    security_groups = ["${aws_security_group.eks-cluster.id}"]
  }

  ingress {
    description     = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.eks-cluster.id}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["76.25.233.7/32"]
    description = "Allow workstation to communicate with the cluster nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      "ingress",
    ]
  }

  tags = "${
    map(
     "Name", "tf-eks-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )
  }"
}
