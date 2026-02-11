# SRE AWS Terraform Project

## Architecture
Client -> API Gateway -> Lambda -> DynamoDB  
Terraform manages all infrastructure. State is stored in S3 with DynamoDB locking.

## Security
- IAM role for Lambda (least privilege)
- No static access keys on compute
- API Gateway permission via resource policy

## CI/CD
- GitHub Actions runs terraform init/plan/apply
- Rollback via git revert

## Monitoring
- CloudWatch logs for Lambda
- CloudWatch alarm on Lambda Errors

## How to Test
curl -X POST -H "Content-Type: application/json" -d '{"message":"hello"}' <API_URL>/message
