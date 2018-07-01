resource "aws_eks_cluster" "cluster_1" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.eks-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${aws_subnet.public.*.id}"]
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]
}

resource "aws_security_group" "eks-cluster" {
  name        = "tf-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["76.25.233.7/32"]
    description = "Allow workstation to communicate with the cluster API Server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow cluster egress access to the Internet."
  }

  lifecycle {
    ignore_changes = [
      "ingress",
    ]
  }

  tags {
    Name = "tf-eks-main"
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-node.id}"
  type                     = "ingress"
  description              = "Allow nodes to communicate with the cluster API Server"
}
