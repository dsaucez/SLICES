# Provision resources in the cloud

We currently support automated provisioning of resources in OpenStack and in
Google Cloud Platform.

First initialize terraform to get all modules with:

```console
terraform init
```

Then modify `gcp.tfvars` or `openstack.tfvars` according to your needs. Once
updated, run the following command to provision GCP


```console
terraform apply -auto-approve -var-file="gcp.tfvars"
```

or the following command to provision OpenStack

```console
terraform apply -auto-approve -var-file="openstack.tfvars"
```


## Variables and attributes

> **TBD**