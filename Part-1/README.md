This project provisions infrastructure in Azure using Terraform and deploys frontend and backend apps as containers, exposed through Azure Application Gateway.

How to run:

1. Clone the repo
2. Create a terraform.tfvars file and add your subscription_id:

```
subscription_id = "your_azure_subscription_id"
name_prefix = "fullstackapp"
location = "West Europe"
```

1. terraform init
2. terraform plan
3. terraform apply

TODO:
Replace hardcoded values to variables.tf
