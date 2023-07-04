STACK_NAME=${1:-awsbootstrap}
EC2_INSTANCE_TYPE=${2:-t2.micro}
REGION=${3:-eu-west-1}
CLI_PROFILE=${4:-default}

AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile $CLI_PROFILE \
  --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

#Deploy static resources
echo -e "\n\n ============ Deploying setup.yml ============"
aws cloudformation deploy \
  --region $REGION \
  --profile $CLI_PROFILE \
  --stack-name $STACK_NAME \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodePipelineBucket=$CODEPIPELINE_BUCKET

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
    --profile ${CLI_PROFILE} \
    --query "Exports[?Name=='InstanceEndpoint'].Value"
fi