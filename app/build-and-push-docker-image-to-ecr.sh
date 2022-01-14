AWS_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
ECR_URI=$(aws ecr describe-repositories | jq ".repositories[0].repositoryUri" -r )
NODE_APP_NAME=node-app-metrics

aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build --tag $NODE_APP_NAME .
docker tag $NODE_APP_NAME\:latest $ECR_URI

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker push $ECR_URI\:latest

kubectl rollout restart deployment node-app-metrics-deployment