Link to the Tutorial:
https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build

|Commands|Descriptions|
|--|--|
|az login|                                                                                      |
|az account set --subscription "35akss-subscription-id"|                                        |
|az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"|     |
|||
|||
|||

$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"

|Commands|Descriptions|
|--|--|
|terraform init                     ||
|terraform init upgrade             ||
|terraform fmt                      ||
|terraform validate                 ||
|terraform plan -out main.tfplan    ||
|terraform apply                    ||
|terraform apply main.tfplan        ||
|terraform show                     ||
|terraform state list               ||
|terraform destroy                  ||
