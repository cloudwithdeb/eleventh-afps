#!/bin/bash

# Define variables
CONTAINERAPP_ENVIRONMENT="eleventh-efps-signup-container-environment"
STORAGE_RESOURCE_GROUP="azEleventhEfpStorageAccountResourceGroup"
CONTAINER_APP_NAME_STAGE="eleventh-efps-stage-signup-containerapp"
CONTAINER_APP_NAME_PROD="msk-prod-signup-containerapp"
STORAGE_ACCOUNT3_NAME="mskstagestorage428"
WORKSPACE_NAME="msk-signup-log-analytics"
RESOURCE_GROUP="azMSKSignupResourceGroup"
STORAGE_ACCOUNT2_NAME="mskprodstorage428"
STORAGE_ACCOUNT1_NAME="mskdevstorage428"
IMAGE_NAME="msk-signup"
LOCATION="westeurope"
USERNAME="debcloud"
PORT=5123

#Build and push docker image to docker hub
docker image build -t $IMAGE_NAME . --no-cache
docker image tag $IMAGE_NAME $USERNAME/$IMAGE_NAME
docker image push $USERNAME/$IMAGE_NAME

# (1). Deploy Nodejs Container App
DoesResourceGroupExists=$(az group exists -n $RESOURCE_GROUP)

if [[ $DoesResourceGroupExists -eq false ]]
then

    az provider register --namespace Microsoft.App

    # Create resource group for container app
    az group create --name $RESOURCE_GROUP --location $LOCATION

    # Create log analytics workspace for container app
    az monitor log-analytics workspace create -g $RESOURCE_GROUP -n $WORKSPACE_NAME

    # Create container app workspace ID
    WORKSPACE_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $WORKSPACE_NAME -o tsv | tr -d '[:space:]'`
    WORKSPACE_PRIMARY_KEY=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $WORKSPACE_NAME -o tsv | tr -d '[:space:]'`

    # Create container app environment
    az containerapp env create --name $CONTAINERAPP_ENVIRONMENT --logs-workspace-key $WORKSPACE_PRIMARY_KEY \
    --resource-group $RESOURCE_GROUP --location $LOCATION --logs-workspace-id $WORKSPACE_ID
    
    # Stage signup container app
    az containerapp create -n $CONTAINER_APP_NAME_STAGE --resource-group $RESOURCE_GROUP \
    --environment $CONTAINERAPP_ENVIRONMENT --image $USERNAME/$IMAGE_NAME  \
    --target-port $PORT --ingress 'external' --target-port $PORT \
    --query properties.configuration.ingress.fqdn  --min-replicas 0 --max-replicas 3 \
    --env-vars DEV_URL="https://mskdevstorage428.table.core.windows.net" ORGANIZATION="mskOrganization" USERS_LOGIN="mskUsersLogin" \
    PROD_URL="https://mskprodstorage428.table.core.windows.net" EMPLOYEES="mskEmployees" TAGS="mskTag" IMAGE_UPLOADS="msk-imageuploads" \
    STAGE_URL="https://mskprodstorage428.table.core.windows.net" SUBSCRIPTION="mskSubscription" CATEGORY="mskCategory" \
    WAREHOUSE="mskWarehouse" USERS_ROLES="mskUsersRoles" REGISTERED_USERS="mskRegisteredUsers" --cpu 1.5 --memory 3.0Gi \

    # Prod signup container app
    az containerapp create -n $CONTAINER_APP_NAME_PROD --resource-group $RESOURCE_GROUP \
    --environment $CONTAINERAPP_ENVIRONMENT --image $USERNAME/$IMAGE_NAME  \
    --target-port $PORT --ingress 'external' --target-port $PORT \
    --query properties.configuration.ingress.fqdn  --min-replicas 0 --max-replicas 7 \
    --env-vars DEV_URL="https://mskdevstorage428.table.core.windows.net" ORGANIZATION="mskOrganization" USERS_LOGIN="mskUsersLogin" \
    PROD_URL="https://mskprodstorage428.table.core.windows.net" EMPLOYEES="mskEmployees" TAGS="mskTag" IMAGE_UPLOADS="msk-imageuploads" \
    STAGE_URL="https://mskprodstorage428.table.core.windows.net" SUBSCRIPTION="mskSubscription" CATEGORY="mskCategory" \
    WAREHOUSE="mskWarehouse" USERS_ROLES="mskUsersRoles" REGISTERED_USERS="mskRegisteredUsers" --cpu 1.5 --memory 3.0Gi \

    # Stage container app enable managed identity
    az containerapp identity assign -n $CONTAINER_APP_NAME_STAGE -g $RESOURCE_GROUP --system-assigned

    # Prod container app enable managed identity
    az containerapp identity assign -n $CONTAINER_APP_NAME_PROD -g $RESOURCE_GROUP --system-assigned

    # Stage container app principal ID
    DEV_spID=$(az resource list -n $CONTAINER_APP_NAME_STAGE --query [*].identity.principalId --out tsv)

    # Prod container app principal ID
    PROD_spID=$(az resource list -n $CONTAINER_APP_NAME_PROD --query [*].identity.principalId --out tsv)

    # Get subscription ID from azure
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)

    # Stage Container app
    az role assignment create --assignee $DEV_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT1_NAME

     az role assignment create --assignee $DEV_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT2_NAME

    az role assignment create --assignee $DEV_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT3_NAME

    # Production container app
    az role assignment create --assignee $PROD_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT1_NAME

     az role assignment create --assignee $PROD_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT2_NAME

    az role assignment create --assignee $PROD_spID --role 'Contributor' \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$STORAGE_RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT3_NAME
fi 