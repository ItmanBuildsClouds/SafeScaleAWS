# ==================================================
# == 1. VPC & Subnets
# ==================================================
resource "aws_vpc" "main_vpc" {
    cidr_block = var.cidr_block
    tags = {
        Name = "${var.project_name}-vpc"
        Environment = var.environment
    }
}

resource "aws_subnet" "public" {
    for_each = var.public_cidrs
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = each.value
    availability_zone = each.key
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-public-${each.key}"
        Environment = var.environment
    }
}

resource "aws_subnet" "private_app" {
    for_each = var.private_app_cidrs
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = each.value
    availability_zone = each.key
    tags = {
        Name = "${var.project_name}-private_app-${each.key}"
        Environment = var.environment
    }
}

resource "aws_subnet" "private_db" {
    for_each = var.private_db_cidrs
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = each.value
    availability_zone = each.key
    tags = {
        Name = "${var.project_name}-private_db-${each.key}"
        Environment = var.environment
    }
}

# ==================================================
# == 2. Gateways
# ==================================================
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id
    depends_on = [aws_vpc.main_vpc]
    tags = {
        Name = "${var.project_name}-igw"
        Environment = var.environment
    }
}

resource "aws_eip" "eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.eip.id
    subnet_id = values(aws_subnet.public)[0].id
    depends_on = [aws_internet_gateway.igw]
    tags = {
        Name = "${var.project_name}-nat_gw"
        Environment = var.environment
    }
}

# ==================================================
# == 3. Routing
# ==================================================
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.project_name}-public"
        Environment = var.environment
    }
}

resource "aws_route_table" "private_app" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags = {
        Name = "${var.project_name}-private_app"
        Environment = var.environment
    }
}

resource "aws_route_table" "private_db" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "${var.project_name}-private_db"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_rt.id
} 

resource "aws_route_table_association" "private_app" {
    for_each = aws_subnet.private_app
    subnet_id = each.value.id
    route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "private_db" {
    for_each = aws_subnet.private_db
    subnet_id = each.value.id
    route_table_id = aws_route_table.private_db.id
}

# ==================================================
# == 4. Security Groups
# ==================================================
resource "aws_security_group" "alb" {
    name = "${var.project_name}-alb-sg"
    description = "Allow for HTTP/HTTPS from internet"
    vpc_id = aws_vpc.main_vpc.id
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-alb-sg"
        Environment = var.environment
    }
}

resource "aws_security_group" "app" {
    name = "${var.project_name}-app-sg"
    description = "Allows for traffic from ALB and output to Internet"
    vpc_id = aws_vpc.main_vpc.id
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-app-sg"
        Environment = var.environment
    }
}

resource "aws_security_group" "db" {
    name = "${var.project_name}-db-sg"
    description = "Allows for traffic only from app servers"
    vpc_id = aws_vpc.main_vpc.id
    
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.app.id]
    }

    tags = {
        Name = "${var.project_name}-db-sg"
        Environment = var.environment
    }
}

