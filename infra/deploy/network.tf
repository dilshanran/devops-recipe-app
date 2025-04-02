#Network Infrastucture#

resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#internet gateway needed for inbound traffic to the ALB #

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-main" # this come from variable.tf and main.tf #
  }
}

#public subnet for the ALB #

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a" # this come from variable.tf and main.tf #

  tags = {
    Name = "${local.prefix}-public-a" # this come from variable.tf and main.tf #
  }
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-public-a" # this come from variable.tf and main.tf #
  }

}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id

}

resource "aws_route" "public_internet_access_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

#public subnet 2 for the ALB #


resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}b" # this come from variable.tf and main.tf #

  tags = {
    Name = "${local.prefix}-public-b" # this come from variable.tf and main.tf #
  }
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-public-b" # this come from variable.tf and main.tf #
  }

}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id

}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

#private subnet for the internal access only #

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = "${data.aws_region.current.name}a" # this come from variable.tf and main.tf #

  tags = {
    Name = "${local.prefix}-private-a" # this come from variable.tf and main.tf #
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "${data.aws_region.current.name}b" # this come from variable.tf and main.tf #

  tags = {
    Name = "${local.prefix}-private-b" # this come from variable.tf and main.tf #
  }
}

## Endpoints to allow ECS to Access ECR, Cloudwatch, and system manager #
# we need to create 4 endpoints for ECR_API,ECR_dkr, Cloudwatch logs, and system manager messages#

resource "aws_security_group" "endpoint_access" {
  description = "Allow access to ECR, Cloudwatch, and system manager"
  name        = "${local.prefix}-endpoint-access"
  vpc_id      = aws_vpc.main.id

  #ingress mean inbound traffic 
  ingress {
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api" # this come from variable.tf and main.tf #
  vpc_endpoint_type   = "Interface"                                             #two types of endpoints are available Gateway and Interface. Gateway is used for S3 and DynamoDB, while Interface is used for ECR, Cloudwatch, and system manager #
  private_dns_enabled = true

  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids = [aws_security_group.endpoint_access.id]

  tags = {
    Name = "${local.prefix}-ecr-endpoint"
  }
}

# ECR docker endpoint is used to pull images from ECR #

resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface" #two types of endpoints are available Gateway and Interface. Gateway is used for S3 and DynamoDB, while Interface is used for ECR, Cloudwatch, and system manager #
  private_dns_enabled = true

  security_group_ids = [aws_security_group.endpoint_access.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${local.prefix}-dkr-endpoint"
  }
}

# Cloudwatch endpoint is used to send logs to cloudwatch #    
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface" #two types of endpoints are available Gateway and Interface. Gateway is used for S3 and DynamoDB, while Interface is used for ECR, Cloudwatch, and system manager #
  private_dns_enabled = true

  security_group_ids = [aws_security_group.endpoint_access.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${local.prefix}-cloudwatch-endpoint"
  }
}

# Cloudwatch events endpoint is used to send events to cloudwatch #

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface" #two types of endpoints are available Gateway and Interface. Gateway is used for S3 and DynamoDB, while Interface is used for ECR, Cloudwatch, and system manager #
  private_dns_enabled = true

  security_group_ids = [aws_security_group.endpoint_access.id]
  subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "${local.prefix}-ssmmessages-endpoint"
  }
}

# S3 endpoint is used to access S3 bucket #

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway" #two types of endpoints are available Gateway and Interface. Gateway is used for S3 and DynamoDB, while Interface is used for ECR, Cloudwatch, and system manager #

  route_table_ids = [aws_vpc.main.default_route_table_id]

  tags = {
    Name = "${local.prefix}-s3-endpoint"
  }

}

# End of file #
