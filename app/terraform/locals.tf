locals {
  global_const = {
    home_ip = "119.18.1.106"
  }
  aws = {
    ## yellowstone
    "341534577110" = {
      subnet_id = "subnet-08c7f5a02d1af72d9"
      vpc_id    = "vpc-008cf87b68ad9ce9e"
      vpc_cidr  = "172.31.0.0/16"
      extra_ingress_rules = [
        {
          description = "SSH"
          from_port   = 1310
          to_port     = 1310
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    ## greenbush
    "360929817018" = {
      subnet_id = "subnet-02440edc2d10c64cd"
      vpc_id    = "vpc-00acd8095086adf0b"
      vpc_cidr  = "172.31.0.0/16"
      extra_ingress_rules = [
        {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.2.3.4/32"]
        },
        {
          description = "v2ray tcp"
          from_port   = 1210
          to_port     = 1210
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "v2ray udp"
          from_port   = 1210
          to_port     = 1210
          protocol    = "udp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "v2ray tcp"
          from_port   = 1310
          to_port     = 1310
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
    ## purplegrape
    "798086532481" = {
      subnet_id           = "subnet-0758065e297d58199"
      vpc_id              = "vpc-01221f12970975b9c"
      vpc_cidr            = "172.31.0.0/16"
      extra_ingress_rules = []
    }
  }
  global = {
    region  = "ap-southeast-2"
    ami     = "ami-0d9f286195031c3d9"
    home_ip = local.global_const.home_ip
    tags = {
      Name = "vultr"
    }
    instance_type = "t2.micro"
    ingress_rules = [
      {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${local.global_const.home_ip}/32"]
      },
      {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

locals {
  config = merge(local.aws[terraform.workspace], local.global)
}