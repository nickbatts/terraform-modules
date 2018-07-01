# Terraform Module - Elastic Kubernetes Cluster (EKS)
This terraform module creates an Elastic Kubernetes Cluster (EKS) on AWS. It deploys nodes into a public subnet in each availability zone with an Amazon managed Kubernetes master control plane.

## Terraform Variables
The `cluster-kube` module requires 5 variables to be defined in the `variables.tf` file, these variables are defined below

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| asg_desired_count | How many instances would you like in the ASG? | string | `6` | yes |
| cluster_name | Name of the Elastic Kubernetes Cluster | string | `TEST` | yes |
| instance_type | EC2 instance type to use for cluster instances - default: t2.micro | string | `t2.micro` | yes |
| region | AWS region to create kubernetes cluster in | string | `us-east-1` | yes |
| spot_price | If set, ASG will use spot instances with this variable as max bid price. | string | `` | no |

## Usage
```hcl
module "kubernetes" {
  source = "github.com/nickbatts/terraform-modules//cluster-kube"

  asg_desired_count = "${var.asg_desired_count}"
  cluster_name      = "${var.cluster_name}"
  instance_type     = "${var.instance_type}"
  region            = "${var.region}"
  spot_price        = "${var.spot_price}"
}
```

## Outputs
| Name | Description |
|------|-------------|
| config-map-aws-auth | Kubernetes configuration file to authorize nodes to join cluster |
| kubeconfig | kubeconfig ready to be saved to ~/.kube/config to interact with cluster |
- Save the kubeconfig configuration into default location, e.g. `~/.kube/config`
- Save the aws-auth configuration into a file, e.g. `config-map-aws-auth.yaml`
- Run  `kubectl apply -f config-map-aws-auth.yaml`
- Verify the worker nodes are joining the cluster via: `kubectl get nodes --watch`

## Links
- [AWS EKS Overview](https://aws.amazon.com/eks/)
- [Terraform AWS EKS Getting Started](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)

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