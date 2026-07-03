resource "aws_db_subnet_group" "banking" {
  name = "banking-db-subnet-group"

  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "banking-db-subnet-group"
  }
}
resource "aws_security_group" "rds" {

  name = "banking-rds-sg"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "banking" {

  identifier = "banking-db"

  engine = "postgres"

  engine_version = "14.22"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  storage_type = "gp3"

  db_name = "banking"

  username = "postgres"

  ##password = random_password.db_password.result
  password = "Password123!" ##--for testing purpose only, please use random_password resource in production

  db_subnet_group_name = aws_db_subnet_group.banking.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = true

  skip_final_snapshot = true

  deletion_protection = false

  backup_retention_period = 1

  storage_encrypted = true

  multi_az = false

  tags = {
    Name = "Banking PostgreSQL"
  }
}