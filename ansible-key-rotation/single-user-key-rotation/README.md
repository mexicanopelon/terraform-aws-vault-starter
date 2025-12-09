# Vault - AWS Key Rotation

This directory includes a Playbook and supporting files for the rotation of AWS Keys in Hashicorp Vault

## Inputs

|Name|Description|Required|Default|
|----|-----------|--------|-------|
|vault_url|The URL to the Vault Cluster.|Yes||
|vault_token|The token to authenticate with Vault.|Yes||
|vault_mount_point|The location of the Secrets engine that stores the AWS Keys.|Yes||
|vault_secret_path|The path to the Secret in Vault.|Yes||
|aws_iam_user|The IAM user to rotate keys.|Yes||
|aws_access_key|The AWS Access Key used to authenticate with AWS to rotate the Key.|Yes||
|aws_secret_key|The AWS Secret Key used to authenticate with AWS to rotate the Key.|Yes||
|aws_region|The AWS Region used to authenticate with AWS to rotate the Key.|Yes||

## Dependencies

### Collections
- amazon.aws (">=7.0.0")
- community.hashi_vault (">=6.0.0")
