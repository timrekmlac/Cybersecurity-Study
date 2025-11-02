# AWS CLI Security Cheat Sheet

## S3 Buckets

| Command | Description |
|---------|-------------|
| `s3 ls` | Get the bucket name |
| Example: `s3.amazonaws.com/offseclab-assets-public/sites/www/images/amethyst.png` | bucket name = `offseclab-assets-public-axevtewi`<br>object key = `/sites/www/images/amethyst.png` |
| [AWS Docs - Access Bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-bucket-intro.html) | Documentation |
| Use `cloudbrute` or `cloud-enum` | Tools to enumerate S3 buckets |

---

## IAM & Profiles

| Command | Description |
|---------|-------------|
| `aws configure --profile attacker` | Create attacker profile |
| `aws --profile attacker sts get-caller-identity` | Get AccountID |

---

## EC2

| Command | Description |
|---------|-------------|
| `ec2 describe-images --owners amazon --executable-users all --filters ...` | List available AMIs (AWS/public/self-owned) |
| `--filters "Name=description,Values=*Offseclab*"` | Filter images by description |
| `ec2 describe-snapshots` | Enumerate publicly shared EBS snapshots |

---

## IAM User & Access Keys

| Command | Description |
|---------|-------------|
| `iam create-user --user-name enum` | Create a new IAM user |
| `iam create-access-key --user-name enum` | Create access key for IAM user |
| `iam put-user-policy --user-name enum --policy-name <name> --policy-document file://policy.json` | Attach inline policy |
| `aws --profile attacker iam list-user-policies --user-name enum` | Verify attached policies |

---

## S3 Operations

| Command | Description |
|---------|-------------|
| `aws s3 mb s3://offseclab-dummy-bucket-$RANDOM-$RANDOM-$RANDOM` | Create bucket with random name |
| `aws s3api put-bucket-policy --bucket <bucket> --policy file://grant-s3-bucket-read2.json` | Attach bucket policy |
| `aws --profile challenge sts get-access-key-info --access-key-id <key>` | Get account identifier for access key |
| `aws s3 cp s3://bucket/README.md ./` | Copy file locally |
| `aws s3 sync s3://bucket ./localdir/` | Sync bucket contents locally |

---

## Lambda

| Command | Description |
|---------|-------------|
| `aws --profile target lambda invoke --function-name arn:aws:lambda:us-east-1:123456789012:function:test outfile` | Invoke Lambda function |

---

## IAM Policies

| Command | Description |
|---------|-------------|
| `aws iam list-user-policies` | List inline user policies |
| `aws iam list-group-policies` | List inline group policies |
| `aws iam list-attached-user-policies --user-name <user>` | List managed policies for user |
| `aws iam list-attached-group-policies --user-name <group>` | List managed policies for group |
| `aws iam list-groups-for-user --user-name <user>` | Check if user is in any groups |
| `aws iam list-policy-versions --policy-arn arn:aws:iam::aws:policy/job-function/SupportUser` | Check current policy version |
| `aws iam get-policy-version --policy-arn ... --version-id ...` | Retrieve specific version of policy |
| `aws iam list-policies --scope Local` | List only customer-managed policies |
| `aws iam list-policies --only-attached` | List only attached policies |
| `aws iam get-account-summary` | Get IAM summary of account |
| `aws iam list-users` | List IAM users |
| `aws iam list-groups` | List IAM groups |
| `aws iam list-roles` | List IAM roles |

---

## Authorization Details

| Command | Description |
|---------|-------------|
| `aws iam get-account-authorization-details` | Get all IAM users, groups, roles, and policies |
| `aws --profile target iam get-account-authorization-details --filter User Group LocalManagedPolicy Role \| tee account-authorization-details.json` | Export IAM relationships |
| `aws --profile target iam get-account-authorization-details --filter LocalManagedPolicy` | List custom managed policies |
| `aws --profile target iam get-account-authorization-details --filter User` | Show user data |
| `aws --profile target iam get-account-authorization-details --filter User --query "UserDetailList[].UserName"` | List usernames |
| `aws --profile target iam get-account-authorization-details --filter User --query "UserDetailList[?contains(UserName,'admin')].{Name:UserName}"` | List all IAM users containing "admin" |
| `aws --profile target iam get-account-authorization-details --filter User Group --query "{Users: UserDetailList[?Path=='/admin/'].UserName, Groups: GroupDetailList[?Path=='/admin/'].{Name: GroupName}}"` | List IAM users and groups in `/admin/` path |
| `aws --profile target iam get-account-authorization-details --filter User Group --query "UserDetailList[?UserName=='admin-alice']"` | Get details for specific user (admin-alice) |
| `aws --profile target iam get-account-authorization-details --filter LocalManagedPolicy --query "Policies[?PolicyName=='amethyst_admin']"` | Show policy details for amethyst_admin |
| `aws --profile challenge ec2 describe-vpcs --query "Vpcs[].Tags[?Key=='proof']"` | Show tagged VPCs |

