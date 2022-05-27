#!/bin/bash
TABLE_STORAGE_ACCOUNT_URL="https://eleventhepfsapp.table.core.windows.net"
CONTAINERAPP_ENVIRONMENT="eleventhepfscontainerenvironment"
SYMPOSIUM_TABLE_NAME="azEleventhEpfsSymposiumTable"
CONTAINER_APP_NAME="eleventh-epfs-containerapp"
EMERGENCY_TABLE="azEleventhEpfsEmergencyTable"
SYMPOSIUM_TABLE="azEleventhEpfsSymposiumTable"
RESOURCE_GROUP="azEleventhEpfsREsourceGroup"
WORKSPACE_NAME="eleventh-efs-log-analytics"
USERS_TABLE="azEleventhEpfsUsersTable"
STORAGE_ACCOUNT_NAME="eleventhepfsapp"
CONTAINER_NAME="eleventhepfs"
IMAGE_NAME="eleventh-epfs"
LOCATION="canadacentral"
STORAGE_KIND="StorageV2"
USERNAME="debcloud"
SKU="Standard_LRS"
PORT=5213

#Build and push docker image to docker hub
docker image build -t $IMAGE_NAME . --no-cache
docker image tag $IMAGE_NAME $USERNAME/$IMAGE_NAME
docker image push $USERNAME/$IMAGE_NAME

DoesResourceGroupExists=$(az group exists -n $RESOURCE_GROUP)
if [[ $DoesResourceGroupExists -eq false ]]
then 

    az provider register --namespace Microsoft.App

    az group create --name $RESOURCE_GROUP --location $LOCATION
    az monitor log-analytics workspace create -g $RESOURCE_GROUP -n $WORKSPACE_NAME

    WORKSPACE_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $WORKSPACE_NAME -o tsv | tr -d '[:space:]'`
    WORKSPACE_PRIMARY_KEY=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $WORKSPACE_NAME -o tsv | tr -d '[:space:]'`

    az containerapp env create --name $CONTAINERAPP_ENVIRONMENT --logs-workspace-key $WORKSPACE_PRIMARY_KEY \
    --resource-group $RESOURCE_GROUP --location $LOCATION --logs-workspace-id $WORKSPACE_ID

    az containerapp create -n $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP --environment $CONTAINERAPP_ENVIRONMENT \
    --image $USERNAME/$IMAGE_NAME  --target-port $PORT --ingress 'external' --target-port $PORT \
    --query properties.configuration.ingress.fqdn  --min-replicas 0 --max-replicas 5 \
    --env-vars TABLE_STORAGE_ACCOUNT_URL=$TABLE_STORAGE_ACCOUNT_URL USERS_TABLE_NAME=$USERS_TABLE \
    EMERGENCY_TABLE_NAME=$EMERGENCY_TABLE SYMPOSIUM_TABLE_NAME=$SYMPOSIUM_TABLE_NAME  \
    STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME STORAGE_ACCOUNT_CONTAINER=$CONTAINER_NAME

    az containerapp identity assign -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --system-assigned
fi


# (2). Deploy storage account if it does not exists
DoesStorageAccountExists=$(az storage account check-name --name $STORAGE_ACCOUNT_NAME --query nameAvailable)

if [[ $DoesStorageAccountExists -eq false ]]
then 
    az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP  -l $LOCATION --sku $SKU --kind $STORAGE_KIND
fi 

# (3). Deploy container if it does not exists
DoesStorageContainerExists=$(az storage container exists --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME -o tsv)

if [[ $DoesStorageContainerExists -eq false ]]
then 
    az storage container create -n $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME  --public-access container
fi

# (4) Deploy users table if it does not exists
DoesUsersTableExists=$(az storage table exists --name $USERS_TABLE --account-name $STORAGE_ACCOUNT_NAME -o tsv)
if [[ $DoesUsersTableExists -eq false ]]
then
    az storage table create --name $USERS_TABLE --account-name $STORAGE_ACCOUNT_NAME
fi

# (5) Deploy emergency table if it does not exists
DoesUsersTableExists=$(az storage table exists --name $EMERGENCY_TABLE --account-name $STORAGE_ACCOUNT_NAME -o tsv)
if [[ $DoesUsersTableExists -eq false ]]
then
    az storage table create --name $EMERGENCY_TABLE --account-name $STORAGE_ACCOUNT_NAME
fi

# (6) Deploy symposium table if it does not exists
DoesSymposiumTableExists=$(az storage table exists --name $SYMPOSIUM_TABLE --account-name $STORAGE_ACCOUNT_NAME -o tsv)
if [[ $DoesSymposiumTableExists -eq false ]]
then
    az storage table create --name $SYMPOSIUM_TABLE --account-name $STORAGE_ACCOUNT_NAME
fi


# Assign Table and container CONTRIBUTER role to managed identity

spID=$(az resource list -n $CONTAINER_APP_NAME --query [*].identity.principalId --out tsv)

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az role assignment create --assignee $spID --role 'Storage Blob Data Contributor' \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME

az role assignment create --assignee $spID --role 'Storage Table Data Contributor' \
--scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME
