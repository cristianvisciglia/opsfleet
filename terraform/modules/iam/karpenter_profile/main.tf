data "aws_iam_policy_document" "karpenter_nodes_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_nodes" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.karpenter_nodes_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.karpenter_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.karpenter_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.karpenter_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.karpenter_nodes.name
}
