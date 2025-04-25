# Database Details#

resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-main"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${local.prefix}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  description = "Allow RDS access"
  name        = "${local.prefix}-rds-inbound-access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432 #postgresql default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]

    security_groups = [
      aws_security_group.ecs_service.id, # Allow access from ECS service security group
    ]
  }
  tags = {
    Name = "${local.prefix}-db-security-group"
  }

}
resource "aws_db_instance" "main" {
  identifier                 = "${local.prefix}-db" ## Optional, but recommended for better readability
  db_name                    = "recipe"
  allocated_storage          = 20 #GB
  storage_type               = "gp2"
  engine                     = "postgres"
  engine_version             = "15.9"
  auto_minor_version_upgrade = true
  instance_class             = "db.t4g.micro"
  publicly_accessible        = false
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.main.name
  skip_final_snapshot        = true
  multi_az                   = false
  backup_retention_period    = 0
  vpc_security_group_ids     = [aws_security_group.rds.id]

  tags = {
    Name = "${local.prefix}-main"
  }
}
