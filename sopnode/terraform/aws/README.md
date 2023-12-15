# Guide to Deploy BluePrint on AWS using terraform?
---

## Goal of this Terraform:

This terraform automates:

1. Creation of 4 virtual machine instances with Ubuntu Linux: Control Node, Master
2. Downloads SLICES github repository on the Control Node.
3. Copies the private key file to the Control Node.
4. Installs Docker

This is all the required infrastructure to start installing the Kubernetes Clusters, OpenAirInterface's 5GCore and 5GRAN on AWS.

**This guide follows Windows based installation. For OS X or Linux, please refer to https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code for more information.**

## Install and Verify Terraform

# Install Terraform
```
choco install terraform
```

### Verify the installation
```
terraform -help
```

Add any subcommand to terraform -help to learn more about what it does and available options.
```
terraform -help plan
```


## Prerequisites
To follow this tutorial you will need:

The [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is installed.
[Terraform is in path](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)
The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed.
[AWS account](https://aws.amazon.com/free) and [associated credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/security-creds.html) that allow you to create resources.

To use your IAM credentials to authenticate the Terraform AWS provider, set the AWS_ACCESS_KEY_ID environment variable.
```
export AWS_ACCESS_KEY_ID=
``` 

Now, set your secret key.
```
export AWS_SECRET_ACCESS_KEY=
``` 

## Configure the Infrastructure

The AWS terraforms are placed in SLICES/sopnode/terraform/aws directory.
The file main.tf defines the infrastructure.

The following steps shows how to customize the configurtion.

### User and Private Key File

The main.tf file assumes that the private key file is named as slices.pem and ssh user as ubuntu. Please modify the user and name of the file accordingly in the locals section of the file as shown here:
```
locals {
    ssh_user  = "ubuntu"
    key_name  = "slices"
    private_key_path  = "~/slices.pem"
}
```

### Customize AWS Region

By default us-east-1 region is configured in the main.tf file. Please modify accordingly, as shown here:
```
provider "aws" {
    region  = "us-east-1"
}
```

### Customize Instance Types

By default the instance types created in the infrastructure are m7g.xlarge instances with ubuntu ami's available in the AWS region us-east-1. Please modify accordingly as shown here:

```
resource "aws_instance" "master" {
  ami           = "ami-0feba2720136a0493"
  subnet_id     = aws_subnet.private.id
  instance_type = "m7g.xlarge"
  security_groups             = [aws_security_group.slices_sg.id]
  key_name                    = local.key_name

  tags = {
    Name = var.instance_master  }
}
```

# Build Infrastructure

## Initialize Terraform

```
terraform init
```

## Execute Terraform and Create Infrastructure

```
terraform apply
```

## Inspect State of Deployment
When you applied your configuration, Terraform wrote data into a file called terraform.tfstate. Terraform stores the IDs and properties of the resources it manages in this file, so that it can update or destroy those resources going forward.

```
terraform show
```

# Destroy Infrastructure
Once you no longer need infrastructure, you may want to destroy it to reduce your security exposure and costs.

Destroy the resources you created.
```
terraform destroy
```
