# Description: This file is used to create the Elastic Beanstalk application for the vprofile application.

resource "aws_elastic_beanstalk_application" "vprofile-prod-dilshan-2" {
  name        = "vprofile-prod-dilshan-2"
  description = "beanstalk application for vprofile"
}