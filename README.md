# `teleport-agent-terraform`

This repo contains a reference Terraform module which configures a Teleport agent for providing access to remote resources via reverse tunnel.

You can use this module to deploy an agent providing any or all of:
- application access
- database access
- node/SSH access

To provide Kubernetes access to remote clusters via Teleport, see the "Kubernetes clusters" section below.

## Example module usage

Write this content to `main.tf` in the directory where you want to keep your Terraform configs.

```terraform
module "teleport-agent-terraform" {
  # source
  source = "github.com/gravitational/teleport-agent-terraform"

  # Teleport Agent name is a unique agent name to identify the individual instance.
  teleport_agent_name = "teleport-database"

  # Teleport proxy hostname/port to connect the agent to - this should include a web UI port like :443 or :3080
  # Any security groups and networking for your agent must permit outbound traffic to flow to this host/port.
  # Don't include https:// in the URL. Any SSL/TLS certificates presented must be valid chains.
  teleport_proxy_hostname = "teleport.example.com:443"

  # Join token which will allow the agent to join the Teleport cluster.
  # This token must already be configured on your cluster and be valid for all Teleport services which the agent is providing access to.
  # i.e. to provide database, application and node/SSH access, the token should be created with
  # tctl tokens add --type=db,app,node
  # See the Teleport static/dynamic token documentation for more details.
  teleport_join_token = "abc123abc123abc123"

  ### Agent mode settings
  ### Note that all of these variables must have a value configured, even if you are not using that mode.
  ### A blank string ("") should be used to avoid setting them.
  # Database
  teleport_agent_db_enabled = "false"
  teleport_agent_db_description = ""
  teleport_agent_db_labels = ""
  teleport_agent_db_name = ""
  teleport_agent_db_redshift_cluster_id = ""
  teleport_agent_db_region = ""
  teleport_agent_db_protocol = ""
  teleport_agent_db_uri = ""

  # App
  teleport_agent_app_enabled = "false"
  teleport_agent_app_description = ""
  teleport_agent_app_labels = ""
  teleport_agent_app_insecure_skip_verify = ""
  teleport_agent_app_name = ""
  teleport_agent_app_public_addr = ""
  teleport_agent_app_uri = ""

  # SSH
  teleport_agent_ssh_enabled = "true"
  teleport_agent_ssh_labels = "env: dev|mode: agent"

  ### Settings for agent deployment
  # List of subnets to spawn agent instances in
  # Note that Teleport application access does not yet de-duplicate available applications, so
  # will show multiple copies of the same application for access if multiple replicas are used.
  # e.g. ["subnet-abc123abc123", "subnet-abc456abc456"]
  # These subnet IDs must exist in the region specified in your provider.tf file
  subnet_ids = ["subnet-abc123abc123", "subnet-abc456abc456"]

  # Instance type used for agent autoscaling group
  agent_instance_type = "t3.medium"

  # SSH key name to provision instances with for emergency access
  # This must be a key that already exists in the AWS account
  key_name = "ops"

  ### Other settings you probably don't need to change
  # AMI ID to use
  # Agents can use OSS AMIs if preferred - Enterprise AMIs are not required.
  # See https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md
  ami_id = "ami-0a96d44f7f99e06c7"

  # AWS KMS alias used for encryption/decryption, defaults to alias used in SSM
  kms_alias_name = "alias/aws/ssm"

  # Account ID which owns the AMIs used to spin up instances
  # You should only need to set this if you're building your own AMIs.
  #ami_owner_account_id = "123456789012"
}

```

Once this file is written, run `terraform init -upgrade && terraform plan && terraform apply`

## Prerequisites

We recommend familiarizing yourself with the following resources prior to reviewing our Terraform examples:

- [Teleport Architecture](https://goteleport.com/docs/architecture/overview/)
- [Admin Guide](https://goteleport.com/docs/admin-guide/)

In order to spin up AWS resources using these Terraform examples, you need the following software:

- terraform v0.13+ [install docs](https://learn.hashicorp.com/terraform/getting-started/install.html)
- awscli v1.14+ [install docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## How to get help

If you're having trouble, check out [Teleport discussions](ttps://github.com/gravitational/teleport/discussions).

## Public Teleport AMI IDs

Please [see the AMIS.md file](https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md) for a list of public Teleport AMI IDs that you can use.

## Kubernetes clusters

To provide Kubernetes access to remote clusters, please use the [`teleport-kube-agent`](https://github.com/gravitational/teleport/tree/master/examples/chart/teleport-kube-agent) Helm chart.

Here is a rough example of how to use the Terraform Helm provider to deploy the chart:

```terraform
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "teleport-kube-agent" {
  name       = "teleport-kube-agent"

  repository = "https://charts.releases.teleport.dev"
  chart      = "teleport-kube-agent"
  version    = "7.1.3"

  set {
    name  = "roles"
    value = "kube"
  }
  # Teleport proxy hostname to connect to
  set {
    name  = "proxyAddr"
    value = "teleport.example.com:443"
  }
  # Join token to use (must be valid for 'kube' service/role)
  set {
    name  = "authToken"
    value = "abc123abc123abc123"
  }
  # Kubernetes cluster name to register with Teleport
  set {
    name  = "kubeClusterName"
    value = "dev-cluster"
  }
}
```

For more detailed use cases, please see the `teleport-kube-agent` README and the Terraform Helm provider docs.