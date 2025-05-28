# TFImageBuilderSetup

Terraform configuration that sets up an AWS EC2 Image Builder pipeline for creating customized Amazon Linux 2 AMIs. Here's a detailed breakdown:

Pipeline Configuration:
   
- Creates an automated image building pipeline
- Runs weekly (Tuesdays at 8 AM)
- Includes image testing
- 60-minute timeout for tests

    

    Image Recipe:

    Based on Amazon Linux 2
    Includes 100GB GP3 EBS volume
    Version 1.0.0
    Includes a simple "hello world" component

    Component Definition:

    Creates a basic Linux component
    Executes a simple bash command ("echo 'hello world'")
    Continues on failure

    Infrastructure Configuration:

    Uses t2.micro instances
    Uses "Ec2Imagebuilder" instance profile - custom one would be needed
    Terminates instances on failure
    Logs to S3 bucket "Your bucket name"

    Distribution Configuration:

    Configures AMI distribution
    Tags AMIs with Project="IT"
    Names AMIs using build date
    Restricts launch permissions to specific account (Input your account here)
    Distributes to eu-west-* regions

This configuration creates an automated pipeline that:

  Builds custom AMIs weekly
  Includes basic customization
  Tests the resulting image
  Distributes the AMI with specific permissions
  Maintains logs of the build process

Common use cases:

  Maintaining standardized, up-to-date AMIs
  Automated OS patching
  Consistent image creation
  Compliance requirements

