
data "aws_vpc" "default" {
  default = true
}

# Create a security group in the default VPC
resource "aws_security_group" "default_vpc_sg" {
  name   = "default-vpc-ssh-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow SSH from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "default-vpc-ssh-sg"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  # Allow EC2 instances to assume the role
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }

}
data "aws_iam_policy_document" "full_access" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.full_access.json
}


resource "aws_iam_role" "role" {
  name               = "test_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_key_pair" "deployer" {
  key_name   = "mlops-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLbvK54vIerAX344EW1JL7LPkSs2pAFmgv3W+UF5gdQCrGfQubCMKFeJ2nfO4W4tigrh09CfIyjWqDARcuR6nkjXl382xPMYx06Dqjm8Yjzs7HDCFYuohwJmP5A/DSQ76omuia1JTVpnN1c4WHyyZcKhvxCJUfKHdxlK+sW2AOEzu1i0FSHNmGI9Eeru7U/OAxjw+Tt3zrEvy8HJSV+ip2/M9Hn05YyXFB15lCC8F/+C/ifH9kV7SZkrhZ/mUG5iC+eV8HWu4QKCk4+V+By7SGjCRqLnM9+ksS0Tj/etRh302R3FQAb8pjiH9ymeQfhEZ7euJ5v5yqhdhFsJXE9ql1NA+BYlenvtf7Pj0135zLbl5pnpBDsIRtpDA/x9tw6Ms1M9T9aoaidZ2JIw2Fc/CE2Cbw+8N/m+UukepWTvq48ZTt6DDBDBhEMKsldafEmUiEQOMVjH2DiC8ZrFay2J31hgB5aiCGljCVmdtQnf09dhYJBUoACDzJRM1qDKBxfAY0DGjXFnFqkaHwk+fggfC9DNUmSlt7eKbpYekSxp/B84vhOsVa0gsHuxQtqgO3WsOEz4IA3tHTXmKprHRylWrqtEZxl79DXuJ62FzEkb/S6twbyRlFnotSYLtGPPkhL8cXiTT74duMvg1oOTtTa5PkGJhVKsikgezzYX9cRj8sRw== r.ali@reply.de"
}

resource "aws_instance" "machine" {
  key_name          = aws_key_pair.deployer.key_name
  ami               = "ami-071878317c449ae48"
  # availability_zone = "euc1-az2"
  instance_type     = "m5a.xlarge"
  tags = { Name : "mlops-cop",
    project : "MLOps LLM Deployment",
    user : "r.ali@reply.de",
  validity : "1" }

  volume_tags = { Name : "mlops-cop",
    project : "MLOps LLM Deployment",
    user : "r.ali@reply.de",
  validity : "1" }
  root_block_device {
    volume_size = 40
    # (8 unchanged attributes hidden)
  }





  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  vpc_security_group_ids = [aws_security_group.default_vpc_sg.id]
  user_data              = file("${path.module}/code/ec2.sh")


}

output "instance_ip" {
  value = aws_instance.machine.public_ip
}
