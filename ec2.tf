
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

# resource "aws_ebs_volume" "example" {
#   availability_zone = "eu-central-1a"
#   size              = 30
# }


# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.example.id
#   instance_id = aws_instance.machine.id
# }

resource "aws_instance" "machine" {
  key_name      = "personal-mlops"
  ami           = "ami-071878317c449ae48"
  availability_zone = "eu-central-1a"
  instance_type = "m5a.xlarge"
    root_block_device {
      tags                  = {}
    volume_size           = 40
    # (8 unchanged attributes hidden)
  }



  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  vpc_security_group_ids = [aws_security_group.default_vpc_sg.id]
  user_data = file("${path.module}/code/ec2.sh")


}





