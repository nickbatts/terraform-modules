# Terraform Module - Virtual Private Cloud (VPC)
This terraform module creates a Virtual Private Cloud (VPC) on AWS. It makes a public and private, if specified, subnet in each availability zone by default.

## Terraform Variables
The vpc module requires a number of variables to be defined in the `variables.tf` file, these variables are defined below

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloud_name | Name of the Virtual Private Cloud | string | `AppCloud` | yes |
| enable_private_subnet | Enable private subnet and get charged for provisioned NAT gateway | boolean | `false` | yes |
| region | AWS region to create resources in | string | `us-west-1` | yes |

## Usage
```
module "vpc" {
  source = "github.com/nickbatts/terraform-modules//vpc"

  cloud_name = "${var.cloud_name}"
  environment = "${var.environment}"
  region      = "${var.region}"
}
```

## Links
- [AWS VPC Overview](https://aws.amazon.com/vpc/)
- [Terraform AWS VPC Resource](https://www.terraform.io/docs/providers/aws/r/vpc.html)

## Author
* Module maintained by [Nick Batts](https://github.com/nickbatts) and other [awesome contributors](https://github.com/nickbatts/terraform-modules/graphs/contributors).

## License
MIT License

Copyright © 2018 Nick Batts

>Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.