# The bucket-root policy defines the API actions that are
# allowed to take place on the bucket root directory.
#
# Given that by default nothing is allowed, here we list
# the actions that are meant to be allowed.
#
# This list of actions that are required by the Docker Registry
# can be found in the official Docker Registry documentation.
data "aws_iam_policy_document" "bucket-root" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "arn:aws:s3:::${var.bucket}",
    ]
  }
}

# Define a base policy document that dictates which principals
# the roles that we attach to this policy are meant to affect.
#
# Given that we want to grant the permissions to an EC2 instance,
# the pricipal is not an account, but a service: `ec2`.
#
# Here we allow the instance to use the AWS Security Token Service
# (STS) AssumeRole action as that's the action that's going to
# give the instance the temporary security credentials needed
# to sign the API requests made by that instance.
data "aws_iam_policy_document" "default" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

# Creates an IAM role with the trust policy that enables the process
# of fetching temporary credentials from STS.
#
# By tying this trust policy with access policies, the resulting 
# temporary credentials generated by STS have only the permissions 
# allowed by the access policies.
resource "aws_iam_role" "main" {
  name               = "default"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

# Attaches an access policy to that role.
resource "aws_iam_role_policy" "bucket-root" {
  name   = "bucket-root-s3"
  role   = aws_iam_role.main.name
  policy = data.aws_iam_policy_document.bucket-root.json
}


# Creates the instance profile that acts as a container for that
# role that we created that has the trust policy that is able
# to gather temporary credentials using STS and specifies the
# access policies to the bucket.
#
# This instance profile can then be provided to the aws_instance
# resource to have it at launch time.
resource "aws_iam_instance_profile" "main" {
  name = "instance-profile"
  role = aws_iam_role.main.name
}

