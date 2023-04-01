# Instances

resource "aws_instance" "aws_linux" {
    count = 2
    ami                         = var.ami[data.aws_region.current.name]
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.private_subnet[count.index].id
    vpc_security_group_ids      = [aws_security_group.aws-linux-sg[count.index].id]

    tags = {
        Name = "instance_${count.index}-${local.project_name}"
    }
}

# Load Balancer

resource "aws_lb" "load_balancer" {
  name                = "load-balancer-${local.project_name}"
  load_balancer_type  = "application"
  subnets             = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  security_groups    = [aws_security_group.load_balancer_sg.id]
  enable_deletion_protection = false
  internal = false

  tags = {
    Name = "load_balancer-${local.project_name}"
  }
}

# RDS (DB)

resource "aws_db_subnet_group" "db_subnet" {
  name = "db_subnet"
  subnet_ids  = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  tags = {
    Name = "db_subnet_${local.project_name}"
  }
}

resource "aws_db_instance" "db_instance" {
  db_name              = "db"
  identifier           = "db-instance"
  engine               = "postgres"
  engine_version       = "12"
  instance_class       = "db.t2.micro"
  allocated_storage    = 2
  username             = "db_admin"
  password             = "adm0@"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name    = "${aws_db_subnet_group.db_subnet.name}"
  tags = {
    name = "db_${local.project_name}"
  }
}

# VPC

resource "aws_vpc" "vpc" {
  cidr_block           = "10.11.0.0/16"
  enable_dns_hostnames = true
  tags = {
   name = "vpc_${local.project_name}"
 }
}

resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.vpc.id
 tags = {
   name = "internet_gateway_${local.project_name}"
 }
}

resource "aws_subnet" "public_subnet" {
    count = length(data.aws_availability_zones.available.names)
    vpc_id            = aws_vpc.vpc.id
    cidr_block = "10.11.${10+count.index}.0/24"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = true
    
    tags = {
        name = "public_subnet_${local.project_name}-${count.index}"
    }
}

resource "aws_subnet" "private_subnet" {
    count = length(data.aws_availability_zones.available.names)
    vpc_id            = aws_vpc.vpc.id
    cidr_block = "10.11.${20+count.index}.0/24"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    map_public_ip_on_launch = false
    
    tags = {
        name = "private_subnet_${local.project_name}-${count.index}"
    }
}


# Security Groups

resource "aws_security_group" "aws-linux-sg" {
  count = 2
  name        = "aws-linux-sg_${count.index}"
  description = "Allow incoming traffic to the Ubuntu EC2 Instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
        description = "ingoing traffic"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      description = "outgoing traffic"
      cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        protocol    = "-1"
        to_port     = "0"
  }

  tags = {
    name = "aws-linux-sg_${count.index}-${local.project_name}"
  }
  
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer_sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description = "ingoing traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ingoing traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "load_balancer_sg_${local.project_name}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ingoing traffic"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "db_sg_${local.project_name}"
  }
}