# FIX CloudFormation Stack Templates

## Description

This repository hosts the [CloudFormation templates](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://fixpublic.s3.amazonaws.com/aws/fix-role-dev-eu.yaml&stackName=FixAccess&param_FixTenantId=00000000-0000-0000-0000-000000000000&param_FixExternalId=00000000-0000-0000-0000-000000000000) for [FIX SaaS](https://fix.tt/) cross-account access, available at [https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml) and [https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml).

The repository aims to provide a publicly auditable history of the FIX CloudFormation template.

The stack sets up a cross-account access role, allowing FIX to access your AWS account. This role, created within your AWS account and assumable by FIX, enables security scans in your account. Additionally, a Lambda function is generated to trigger a callback to FIX, notifying us of the role's name, the account ID in which the role was created, and the ARN of the stack. This information verifies the successful creation and assumability of the role by FIX.

## CloudFormation Template Parameters

The CloudFormation template requires the following parameters:

| Parameter | Description |
| ---------- | ---------- |
| `FixTenantId`   | Your FIX-assigned Tenant ID |
| `FixExternalId` | Your FIX-assigned External ID |

These parameters are generated and provided by FIX, accessible within your FIX account settings, and are pre-populated when using the links in the FIX application.

## CloudFormation Resources

The CloudFormation template creates the following resources:

* `FixCrossAccountAccessRole` ([AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)): This cross-account access role enables FIX to access your AWS account.
* `FixAccessFunction` ([Custom::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources-lambda.html)): This custom resource triggers a Lambda function callback to FIX, though it does not create an actual resource in the AWS account.
* `FixAccessCallbackFunction` ([AWS::Lambda::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html)): This Lambda function facilitates the callback to FIX.
* `FixAccessCallbackFunctionRole` ([AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)): This IAM role permits the Lambda function to execute.
* `FixAccessCallbackLogGroup` ([AWS::Logs::LogGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-logs-loggroup.html)): This CloudWatch log group is associated with the Lambda function. While Lambda would automatically create a log group upon function execution, having it defined within the stack ensures its deletion if the stack is removed.

## FIX Cross Account Access Role

The role is established with a trust policy allowing FIX to assume the role. For enhanced security, it utilizes an external ID. The role grants the following permissions: ReadOnlyAccess.

## Technical Details of the Callback API

The Lambda function issues an HTTP POST request to the following URLs:
- `https://app.us.fixcloud.io/api/cloud/callbacks/aws/cf` for the FIX US environment.
- `https://app.eu.fixcloud.io/api/cloud/callbacks/aws/cf` for the FIX EU environment.

The request body comprises a JSON object with this structure:

```json
{
    "tenant_id": "<your FIX tenant ID>",
    "external_id": "<your FIX external ID>",
    "account_id": "<the AWS account ID where the role was created>",
    "role_name": "<the name of the created role>",
    "stack_id": "<the ARN of the created stack>"
}
```

FIX leverages the tenant_id and external_id to authenticate the request's origin. The account_id and role_name are used to construct the ARN that FIX will assume when performing security scans, while the stack_id offers user convenience within the FIX UI by providing a link to the CloudFormation stack in the AWS console.
