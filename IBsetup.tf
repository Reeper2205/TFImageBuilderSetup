terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_imagebuilder_image_pipeline" "this" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  name                             = "amazon-linux-baseline"
  status                           = "ENABLED"
  description                      = "Creates an Amazon Linux 2 image."


  schedule {
    schedule_expression = "cron(0 8 ? * tue)"
    # This cron expressions states every Tuesday at 8 AM.
    pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
  }

  # Test the image after build
  image_tests_configuration {
    image_tests_enabled = true
    timeout_minutes     = 60
  }

}

resource "aws_imagebuilder_image" "this" {
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn

}

resource "aws_imagebuilder_image_recipe" "this" {
  block_device_mapping {
    device_name = "/dev/xvdb"

    ebs {
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp3"
    }
  }

  component {
    component_arn = aws_imagebuilder_component.this.arn
  }

  name         = "Hello-world"
  parent_image = "arn:aws:imagebuilder:eu-west-1:aws:image/amazon-linux-2-x86/x.x.x"
  version      = "1.0.0"
}

resource "aws_imagebuilder_component" "this" {
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        action = "ExecuteBash"
        inputs = {
          commands = ["echo 'hello world'"]
        }
        name      = "Hello-world"
        onFailure = "Continue"
      }]
    }]
    schemaVersion = 1.0
  })
  name     = "Hello-world"
  platform = "Linux"
  version  = "1.0.0"
}


resource "aws_imagebuilder_infrastructure_configuration" "this" {
  description           = "Simple infrastructure configuration"
  instance_profile_name = "Ec2ProfileForImageBuilder"
  instance_types        = ["t2.micro"]
  name                  = "amazon-linux-infr"


  terminate_instance_on_failure = true

  logging {
    s3_logs {
      s3_bucket_name = "BUCKET_NAME"
      s3_key_prefix  = "/ImageBuilder"
    }
  }

  tags = {
    Name = "amazon-linux-infr"
  }
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  name = "local-distribution"

  distribution {
    ami_distribution_configuration {
      ami_tags = {
        Project = "IT"
      }

      name = "amzn-linux-{{ imagebuilder:buildDate }}"

      launch_permission {
        user_ids = ["ACCOUNTNUMBER"]
      }
    }
    region = "eu-west-1"
  }
}
