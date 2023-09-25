# FIX CloudFormation Stack Templates

## Description

This repository contains the CloudFormation templates for the [FIX SaaS](https://fix.tt/) cross account access, hosted at [https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml) and [https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml).

The purpose of this repository is to provide a publicly auditable history of the FIX CloudFormation template.

The stack creates a cross account access role that allows FIX to access your AWS account. The role is created in your AWS account and is assumable by FIX for the purpose of performing security scans in your account. In addition the stack creates a Lambda function that triggers a callback to FIX, letting us know the name of the role that was created, the account id of the account the role was created in as well as the ARN of the stack. This allows us to verify that the role was created successfully and that the role is assumable by FIX.


## CloudFormation Template Parameters

The following parameters are required for the CloudFormation template:

| Parameter | Description |
| ---------- | ---------- |
| `FixTenantId`   | Your FIX assigned tenant ID |
| `FixExternalId` | Your FIX assigned external ID |

Both of these are generated and provided by FIX. They can be found in your FIX account settings and are pre-filled when using the links in the FIX application.

## CloudFormation Resources

The following resources are created by the CloudFormation template:

`FixCrossAccountAccessRole` ([AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)) - The cross account access role that allows FIX to access your AWS account.
`FixAccessFunction` ([Custom::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources-lambda.html)) - This custom resource is used to trigger the Lambda function that calls back to FIX.
`FixAccessCallbackFunction` ([AWS::Lambda::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html)) - The Lambda function that calls back to FIX.
`FixAccessCallbackFunctionRole` ([AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)) - The IAM role that allows the Lambda function to run.
`FixAccessCallbackLogGroup` ([AWS::Logs::LogGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-logs-loggroup.html)) - The CloudWatch log group for the Lambda function that calls back to FIX.


## FIX Cross Account Access Role

The role is created with a trust policy that allows FIX to assume the role. For extra security it is using a external ID. The role is created with the following permissions: ReadOnlyAccess


## Technical Details of the Callback API

The Lambda function sends a HTTP POST request to the following URL:
- `https://app.us.fixcloud.io/api/cloud/callbacks/aws/cf` if you're using the FIX US environment
- `https://app.eu.fixcloud.io/api/cloud/callbacks/aws/cf` if you're using the FIX EU environment

The request body is a JSON object with the following structure:

```json
{
    "tenant_id": "<your FIX tenant ID>",
    "external_id": "<your FIX external ID>",
    "account_id": "<the AWS account ID the role was created in>",
    "role_name": "<the name of the role that was created>",
    "stack_id": "<the ARN of the stack that was created>"
}
```

FIX uses the tenant_id and external_id to verify that the request is coming from a valid user. The account_id and role_name are used to construct the ARN that FIX will use to assume the role when performing a security audit. The stack_id is used by the FIX UI for user convenience, to provide a link to the CloudFormation stack in the AWS console.
