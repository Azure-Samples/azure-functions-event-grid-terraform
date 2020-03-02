#! /bin/bash

if [ $# -lt 2 ]
  then
    echo "Usage: ./deploy.sh <subscription id> <unique prefix>"
    exit 1
fi

az account set --subscription $1 &> /dev/null
if [ $? -ne 0 ]; then
  az login > /dev/null
fi

[ $? -ne 0 ] && exit $?

az account set --subscription $1

[ $? -ne 0 ] && exit $?

echo 'Deploying Terraform sandwich "top bun"...'
cd infrastructure/terraform
terraform init -reconfigure -upgrade=true > /dev/null
terraform apply -var prefix=$2 -target module.functions -compact-warnings

[ $? -ne 0 ] && exit $?

cd ../../src/FunctionApp

echo "Deploying Function App..."
sleep 3
func azure functionapp list-functions $2-fxn &> /dev/null
while [ $? -ne 0 ] ;
do
  sleep 3
  func azure functionapp list-functions $2-fxn &> /dev/null
done

func azure functionapp publish $2-fxn --csharp > /dev/null

[ $? -ne 0 ] && exit $?

echo 'Deploying Terraform sandwich "bottom bun"...'
cd ../../infrastructure/terraform
terraform apply -var prefix=$2 -compact-warnings