Terraform How To's by Parth
=================

Let's getting rolling with terraform

- Check provider page on how to install this shit
- Doc: https://www.terraform.io/docs/providers/google/index.html

Add any subcommand to terraform -help to learn more about what it does and available options.

```
$ terraform -help plan
```
Then install the autocomplete package.
```
$ terraform -install-autocomplete
```

Terraform Block
------------------
### Example code block used to create a vpc from the terraform-gke-create-vpc folder

```tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}
variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "terraform-network"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "terraform-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
```

- Terraform block -> contains Terraform settings including required providers to be used to provision infra. 

Source attribute defines an optional hostname, namespace and provider type. This info can be found here: https://registry.terraform.io/. 

In this example configuration, the google provider's source is defined as hashicorp/google, which is shorthand for registry.terraform.io/hashicorp/google

You can also define a version constraint for each provider in the required_providers block. The version attribute is optional, but we recommend using it to enforce the provider version. Without it, Terraform will always use the latest version

- Providers ->  A provider is a plugin that Terraform uses to create and manage your resources. You can define multiple provider blocks in a Terraform configuration to manage resources from different providers
  
- Resources -> Use resource blocks to define components of your infrastructure. A resource might be a physical component such as a server, or it can be a logical resource such as an application.

Resource blocks have two strings before the block: the resource type and the resource name. In this example, the resource type is **google_compute_network** and the name is **vpc_network**. The prefix of the type maps to the name of the provider. In the example configuration, Terraform manages the **google_compute_network** resource with the google provider. Together, the resource type and resource name form a unique ID for the resource. For example, the ID for your network is **google_compute_network.vpc_network**.

The [Terraform Registry GCP](https://registry.terraform.io/providers/hashicorp/google/latest/docs) documentation page documents the required and optional arguments for each GCP resource

### Some commands to remember after creating the .tf file

```
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
terraform show -> used to inspect the current state
terraform state list -> to show list of the stuff created by terraform
```