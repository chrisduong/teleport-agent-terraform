# Teleport agent name is a unique name to identify the individual agent instance.
variable "teleport_agent_name" {
  type = string
}

# Teleport proxy hostname to connect to - this should include a web UI port like :443 or :3080
# The security groups and networking for the agent must permit traffic to flow to this host/port.
# Don't include https:// in the URL. Any SSL/TLS certificates presented must be valid chains.
variable "teleport_proxy_hostname" {
  type = string
}

# Join token to use to join the Teleport cluster
# This token must already be configured on your cluster and be valid for all Teleport services which the agent is providing access to.
# i.e. to provide database, application and node/SSH access, the token should be created with
# tctl tokens add --type=db,app,node
variable "teleport_join_token" {
  type = string
}

# Agent settings
# DB
variable "teleport_agent_db_enabled" {
  type = string
}

variable "teleport_agent_db_description" {
  type = string
}

variable "teleport_agent_db_labels" {
  type = string
}

variable "teleport_agent_db_name" {
  type = string
}

variable "teleport_agent_db_redshift_cluster_id" {
  type = string
}

variable "teleport_agent_db_region" {
  type = string
}

variable "teleport_agent_db_protocol" {
  type = string
}

variable "teleport_agent_db_uri" {
  type = string
}

# App
variable "teleport_agent_app_enabled" {
  type = string
}

variable "teleport_agent_app_description" {
  type = string
}

variable "teleport_agent_app_labels" {
  type = string
}

variable "teleport_agent_app_insecure_skip_verify" {
  type = string
}

variable "teleport_agent_app_name" {
  type = string
}

variable "teleport_agent_app_public_addr" {
  type = string
}

variable "teleport_agent_app_uri" {
  type = string
}

# SSH
variable "teleport_agent_ssh_enabled" {
  type = string
}

variable "teleport_agent_ssh_labels" {
  type = string
}

# SSH key name to provision instances with (used for emergency SSH access)
# This must be a key that already exists in the AWS account
variable "key_name" {
  type = string
}

# AMI ID to use
# Agents should always use OSS AMIs - Enterprise AMIs are not required.
# See https://github.com/gravitational/teleport/blob/master/examples/aws/terraform/AMIS.md
variable "ami_id" {
  type = string
}

# List of subnets to spawn agent instances in
# Note that Teleport application access does not yet de-duplicate available applications, so
# will show multiple copies of the same application for access if multiple replicas are used.
# e.g. ["subnet-abc123abc123", "subnet-abc456abc456"]
# These subnet IDs must exist in the region specified in your provider.tf file
variable "subnet_ids" {
  type = set(string)
}

# Instance type used for agent autoscaling group
variable "agent_instance_type" {
  type    = string
  default = "m4.large"
}

# AWS KMS alias used for encryption/decryption, defaults to alias used in SSM
variable "kms_alias_name" {
  default = "alias/aws/ssm"
}

# Account ID which owns the AMIs used to spin up instances
# You should only need to change this if you're building your own AMIs for testing purposes.
# The default is "126027368216" (Gravitational/Teleport's AMI hosting account)
variable "ami_owner_account_id" {
  type    = string
  default = "126027368216"
}