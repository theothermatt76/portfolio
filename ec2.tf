resource "aws_vpc" "$vpc_name" {
  cidr_block = "$network_block"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "$my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "$network_block"
  availability_zone = "$rebion+zone"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "$eni_name" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["$priv_ip"]

  tags = {
    Name = "$some_name"
  }
}

resource "aws_instance" "$instance_name" {
  ami           = "$ami"
  instance_type = "$size"

  primary_network_interface {
    network_interface_id = aws_network_interface.example.id
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}
