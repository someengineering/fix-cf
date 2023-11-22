# FIX CloudFormation Stack Templates

## Description

This repository hosts the [CloudFormation templates](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://fixpublic.s3.amazonaws.com/aws/fix-role-dev-eu.yaml&stackName=FixAccess&param_WorkspaceId=00000000-0000-0000-0000-000000000000&param_ExternalId=00000000-0000-0000-0000-000000000000) for [FIX SaaS](https://fix.tt/) cross-account access, available at [https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-us.yaml) and [https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml](https://fixpublic.s3.amazonaws.com/aws/fix-role-eu.yaml).

The repository aims to provide a publicly auditable history of the FIX CloudFormation template.

The stack sets up a cross-account access role, allowing FIX to access your AWS account. This role, created within your AWS account and assumable by FIX, enables security scans in your account. Additionally, a SNS message is generated to trigger a callback to FIX, notifying us of the role's name, the account ID in which the role was created, and the ARN of the stack. This information verifies the successful creation and assumability of the role by FIX.

## CloudFormation Template Parameters

The CloudFormation template requires the following parameters:

| Parameter | Description |
| ---------- | ---------- |
| `WorkspaceId` | Your FIX-assigned Workspace ID |
| `ExternalId`  | Your FIX-assigned External ID  |

These parameters are generated and provided by FIX, accessible within your FIX account settings, and are pre-populated when using the links in the FIX application.

## CloudFormation Resources

The CloudFormation template creates the following resources:

* `FixCrossAccountAccessRole` ([AWS::IAM::Role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)): This cross-account access role enables FIX to access your AWS account.
* `FixAccountCallback` ([Custom::Function](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources-lambda.html)): This custom resource triggers a SNS message callback to FIX, though it does not create an actual resource in the AWS account.

## FIX Cross Account Access Role

The role is established with a trust policy allowing FIX to assume the role. For enhanced security, it utilizes an external ID. The role grants the following permissions: ReadOnlyAccess.

## Technical Details of the Callback Message

The SNS callback submits the following information to FIX:

```json
{
    "workspace_id": "<your FIX workspace ID>",
    "external_id": "<your FIX external ID>",
    "role_name": "<the name of the created role>",
    "stack_id": "<the ARN of the created stack>"
}
```

FIX leverages the workspace_id and external_id to authenticate the request's origin. The role_name is used to construct the ARN that FIX will assume when performing security scans, while the stack_id is used to retrieve the user's account_id from its ARN.
