#!/bin/bash

# Variables
cluster_name="cluster-1-test"
region="me-south-1"
aws_id="361749389927"
cd terraform
php_img=$(terraform output -raw ecr_php_repository_name)
nginx_img=$(terraform output -raw ecr_nginx_repository_name)
rds_endpoint=$(terraform output -raw rds_cluster_endpoint)
db_username=$(terraform output -raw db_username)
db_password=$(terraform output -raw db_password)
php_image_name="$aws_id.dkr.ecr.$region.amazonaws.com/$php_img:latest"
nginx_image_name="$aws_id.dkr.ecr.$region.amazonaws.com/$nginx_img:latest"
namespace="craftscene-app"
app_service_name="craftscene-nginx-service"
cd ..

cd terraform && \
terraform init
terraform apply -auto-approve
cd ..

# update kubeconfig
echo "--------------------Update Kubeconfig--------------------"
aws eks update-kubeconfig --name $cluster_name --region $region

# remove preious docker images
#echo "--------------------Remove Previous build--------------------"
#docker rmi -f $php_image_name || true
#docker rmi -f $nginx_image_name || true
#
## build new docker image with new tag
#echo "--------------------Build new Image--------------------"
#docker build -t $php_image_name .
#docker build -f nginx/Dockerfile -t $nginx_image_name k8s
#
## ECR Login
#echo "--------------------Login to ECR--------------------"
#aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $aws_id.dkr.ecr.$region.amazonaws.com
#
## push the latest build to dockerhub
#echo "--------------------Pushing Docker Image--------------------"
#docker push $php_image_name
#docker push $nginx_image_name

# Create namespace
echo "--------------------Deploy App--------------------"
kubectl create ns $namespace

# add rds endpoint into k8s secrets
echo "--------------------Create RDS Secrets --------------------"
kubectl create secret -n $namespace generic rds-endpoint --from-literal=endpoint=$rds_endpoint || true
kubectl create secret -n $namespace generic rds-username --from-literal=username=$db_username || true
kubectl create secret -n $namespace generic rds-password --from-literal=password=$db_password || true

# deploy the application
echo "--------------------Deploy App--------------------"
kubectl apply -n $namespace -f k8s/


# Wait for application to be deployed
echo "--------------------Wait for all pods to be running--------------------"
sleep 60s

# Get ingress URL
echo "--------------------Application LoadBalancer URL--------------------"
kubectl get svc -n ${namespace} ${app_service_name}-o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

#kubectl get svc -n craftscene-app craftscene-nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# Get RDS endpoint URL
echo "--------------------RDS endpoint URL--------------------"
echo $rds_endpoint
