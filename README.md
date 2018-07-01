# Terraform Modules
🛠️ This is a set of [Terraform](https://terraform.io/) modules for provisioning common configurations of infrastructure on AWS.

## Requirements
- **Terraform 0.11.7+** - For installation instructions go [here](https://www.terraform.io/intro/getting-started/install.html). Or you can use a Docker image like [this one](https://hub.docker.com/r/hashicorp/terraform/).
- **AWS account** - Free; if you don't have an account you can sign up at https://aws.amazon.com/. By default we use t2.small instances.

## Getting Started
Any of the modules in this directory can be used alone or together with care taken to avoid potential duplicate naming issues.

#### 1) Clone the repo
`$ git clone git@github.com:nickbatts/terraform-modules && cd terraform-modules/`

## Helpful Commands
- `$ terraform init` - load modules from source location and install provider
- `$ terraform plan` - see expected resources to be added, changed or destroyed
- `$ terraform apply` - approve and perform resource modifications

## Author
* Module maintained by [Nick Batts](https://github.com/nickbatts).

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