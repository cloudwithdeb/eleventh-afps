#!/bin/bash
CONTAINER_APP_NAME="eleventh-epfs-containerapp"
RESOURCE_GROUP="azEleventhEpfsREsourceGroup"
IMAGE_NAME="eleventh-epfs"
USERNAME="debcloud"

#Build and push docker image to docker hub
docker image build -t $IMAGE_NAME . --no-cache
docker image tag $IMAGE_NAME $USERNAME/$IMAGE_NAME
docker image push $USERNAME/$IMAGE_NAME

DoesResourceGroupExists=$(az group exists -n $RESOURCE_GROUP)
if [[ $DoesResourceGroupExists -eq false ]]
then 
    az containerapp update -n $CONTAINER_APP_NAME -g $RESOURCE_GROUP --image $USERNAME/$IMAGE_NAME
    echo "New deployment successfully. Thank you!"
fi

echo "Done."
