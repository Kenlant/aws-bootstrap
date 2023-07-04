STACK_NAME=${1:-awsbootstrap}
EC2_INSTANCE_TYPE=${2:-t2.micro}
REGION=${3:-eu-west-1}
CLI_PROFILE=${4:-default}

#Deploy the CloudFormation template
echo -e "\n\n ============ Deploying main.yml ============"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
      EC2InstanceType=$EC2_INSTANCE_TYPE

if [ $? -eq 0 ]; then
  aws cloudformation list-exports \
    --profile default \
    --query "Exports[?Name=='InstanceEndpoint'].Value"
fi