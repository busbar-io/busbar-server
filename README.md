# Busbar

A tool to build, deploy and control applications running on a Kubernetes cluster.


## Overview

Busbar acts as a easy to use interface between developers and a Kubernetes cluster allowing developers to create/deploy/scale/publish applications using simple [busbar-cli](https://github.com/busbar-io/busbar-cli) commands.

Busbar currently is an AWS centric application so access to an AWS account is needed in order to use Busbar.


## Installation and Setup

We are assuming that you already have a working Kubernetes cluster running on AWS. If not please check out [kops](https://github.com/kubernetes/kops).

The steps bellow will show to you resources on setting up the needed AWS components and policies, install Busbar through [helm](https://github.com/kubernetes/helm) and put up a simple Ruby example application.


### AWS Setup

In order to Busbar to work properly you will need to have:
- An private Route53 zone.
- An external Route53 zone.
- A IAM User to be used by the private Docker registry.
- A S3 bucket for the private Docker registry set with the proper policy.


#### Create an private Route53 zone

The private zone will need to be created and associated with the VPC where your Kubernetes cluster is running.

Please check the following AWS documentation in order to create the private zone:
- [Creating a Private Hosted Zone](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zone-private-creating.html)


#### Create an external Route53 zone

Please check the following AWS documentation in order to create the public zone:
- [Creating a Public Hosted Zone](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)


#### Create an IAM User to be used by the private Docker registry

Please check the following AWS documentation in order to create the IAM user to be used by the private Docker registry:
- [Creating an IAM User in Your AWS Account](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)

Don't forget to save the Access/Secret key pairs. They will be used when deploying Busbar into your Kubernetes Cluster.


#### Create a S3 bucket for the private Docker registry and set it with proper policy

Please check the following AWS documentation in order to create a S3 bucket:
- [Create a Bucket](http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html)

The recomended S3 bucket policy is the following (replace the values inside `<` and `>`):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Read-Write",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<aws_account_name>:user/<docker_registry_user_name>"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::<bucket_name>/*",
                "arn:aws:s3:::<bucket_name>"
            ]
        }
    ]
}
```

In order to set the above policy on you newly created bucket, on your AWS web console:
- Navigate to `Service > Storage > S3`
- Click on your bucket name
- Click on `Permissions` tab
- Click on `Bucket Policy` on the `Permissions` tab
- Paste the above policy replacing the needed values by the proper ones

If in doubt on how to set the policy on your bucket please read the following (extensive) documentation:
- [An Example Walkthrough: Using user policies to control access to your bucket](http://docs.aws.amazon.com/AmazonS3/latest/dev/walkthrough1.html)


### Busbar Installation
